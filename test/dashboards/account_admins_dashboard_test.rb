require 'test_helper'

class AccountAdminsDashboardTest < ActiveSupport::TestCase
  subject { AccountAdminsDashboard.new(build(:user, :account_owner)) }
  should delegate_method(:plan_max_employees).to(:account)

  test '#when_show_compliance_stats_for_offices' do
    user = build(:user, :employee)
    subject = AccountAdminsDashboard.new(user)
    block_called = false

    subject.when_show_compliance_stats_for_offices do
      block_called = true
    end

    assert_equal true, block_called
  end

  describe '#when_many_offices' do
    test 'when true' do
      user = users(:employee)
      user.stubs(:account_offices).returns([1, 2, 3])
      subject = AccountAdminsDashboard.new(user)
      block_called = false

      subject.when_many_offices do
        block_called = true
      end

      assert_equal true, block_called
    end

    test 'when false' do
      user = users(:employee)
      user.stubs(:account_offices).returns([1, 2])
      subject = AccountAdminsDashboard.new(user)
      block_called = false

      subject.when_many_offices do
        block_called = true
      end

      assert_equal false, block_called
    end
  end

  test '#offices' do
    account = accounts(:oceanview_dental)
    user = build(:user, account: account)
    subject = AccountAdminsDashboard.new(user)

    result = subject.offices

    assert_kind_of OfficesPresenter, result
  end

  test '#stats_last_updated_at' do
    timestamp = DateTime.parse('2019-08-26 12:00 AM')
    account = create(:account, compliance_stats_last_updated_at: timestamp)
    user = build(:user, account: account)
    subject = AccountAdminsDashboard.new(user)

    result = subject.stats_last_updated_at

    assert_equal 'Mon, Aug 26, 2019 12:00 AM', result
  end

  describe '#document_compliance_percentage' do
    test 'when no stats exist' do
      account = accounts(:oceanview_dental)
      user = build(:user, account: account)
      subject = AccountAdminsDashboard.new(user)

      result = subject.document_compliance_percentage

      assert_equal 0, result
    end

    test 'when stats exist' do
      account = accounts(:oceanview_dental)
      user = build(:user, account: account)
      stats = create(:account_compliance_stats, account: account)
      subject = AccountAdminsDashboard.new(user)

      result = subject.document_compliance_percentage

      assert_equal stats.document_compliance_percentage, result
    end
  end

  describe '#training_compliance_percentage' do
    test 'when no stats exist' do
      account = accounts(:oceanview_dental)
      user = build(:user, account: account)
      subject = AccountAdminsDashboard.new(user)

      result = subject.training_compliance_percentage

      assert_equal 0, result
    end

    test 'when stats exist' do
      account = accounts(:oceanview_dental)
      user = build(:user, account: account)
      stats = create(:account_compliance_stats, account: account)
      subject = AccountAdminsDashboard.new(user)

      result = subject.training_compliance_percentage

      assert_equal stats.training_compliance_percentage, result
    end
  end

  test 'past_due_or_expired_assignments' do
    user = users(:account_manager)
    oceanview_past_due = incomplete_assignments(:oceanview_past_due)
    oceanview_due_soon = incomplete_assignments(:oceanview_due_soon)
    brookside_past_due = incomplete_assignments(:brookside_past_due)
    subject = AccountAdminsDashboard.new(user)

    result = subject.past_due_or_expired_assignments

    assert_equal 1, result.length, "#{result.inspect}"
    assert_includes result.map(&:id), oceanview_past_due.id, 'Oceanview past due should be included'
    refute_includes result.map(&:id), oceanview_due_soon.id, 'Oceanview due soon should NOT be included'
    refute_includes result.map(&:id), brookside_past_due.id, 'Brookside past due should NOT be included'
  end

  test 'due_soon_or_expiring_soon_assignments' do
    user = users(:account_manager)
    oceanview_due_soon = incomplete_assignments(:oceanview_due_soon)
    oceanview_past_due = incomplete_assignments(:oceanview_past_due)
    brookside_due_soon = incomplete_assignments(:brookside_due_soon)
    subject = AccountAdminsDashboard.new(user)

    result = subject.due_soon_or_expiring_soon_assignments

    assert_equal 1, result.length, "#{result.inspect}"
    assert_includes result.map(&:id), oceanview_due_soon.id, 'Oceanview due soon should be included'
    refute_includes result.map(&:id), oceanview_past_due.id, 'Oceanview past due should NOT be included'
    refute_includes result.map(&:id), brookside_due_soon.id, 'Brookside due soon should NOT be included'
  end

  describe '#when_employee_records_exist' do
    test 'when records exist' do
      account = create(:account)
      user = create(:user, :account_owner, account: account)
      document_group = create_employee_document_group_for(account)
      create(
        :employee_record,
        :employed,
        user: user,
        document_group: document_group,
        office: account.offices.first
      )
      subject = AccountAdminsDashboard.new(user)
      block_called = false

      subject.when_employee_records_exist do
        block_called = true
      end

      assert_equal true, block_called
    end

    test 'when no records exist' do
      account = build(:account)
      user = build(:user, :account_owner, account: account)
      subject = AccountAdminsDashboard.new(user)
      block_called = false

      subject.when_employee_records_exist do
        block_called = true
      end

      assert_equal false, block_called
    end
  end

  describe '#when_no_employee_records_exist' do
    test 'when records exist' do
      account = create(:account)
      user = create(:user, :account_owner, account: account)
      document_group = create_employee_document_group_for(account)
      create(
        :employee_record,
        :employed,
        user: user,
        document_group: document_group,
        office: account.offices.first
      )
      subject = AccountAdminsDashboard.new(user)
      block_called = false

      subject.when_no_employee_records_exist do
        block_called = true
      end

      assert_equal false, block_called
    end

    test 'when no records exist' do
      account = build(:account)
      user = build(:user, :account_owner, account: account)
      subject = AccountAdminsDashboard.new(user)
      block_called = false

      subject.when_no_employee_records_exist do
        block_called = true
      end

      assert_equal true, block_called
    end
  end

  test '#expiring_soon_threshold' do
    user = build(:user, :account_owner)
    subject = AccountAdminsDashboard.new(user)

    assert_equal Document::EXPIRING_SOON_THRESHOLD, subject.expiring_soon_threshold
  end
end
