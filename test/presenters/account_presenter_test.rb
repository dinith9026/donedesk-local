require 'test_helper'

class AccountPresenterTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  subject { AccountPresenter.new(nil, nil) }
  should delegate_method(:name).to(:account)
  should delegate_method(:plan_monthly_price_in_cents).to(:account)
  should delegate_method(:plan_max_employees).to(:account)
  should delegate_method(:pending_invites).to(:account)
  should delegate_method(:plan).to(:account)
  should delegate_method(:owner_email).to(:account)
  should delegate_method(:owner_full_name).to(:account)
  should delegate_method(:invite_token).to(:account)
  should delegate_method(:active?).to(:account)
  should delegate_method(:deactivated?).to(:account)

  describe '#when_invites_pending' do
    test 'when invites are pending' do
      account = Account.new
      account.stubs(:pending_invites).returns([1])
      subject = AccountPresenter.new(account, nil)
      block_called = false

      subject.when_invites_pending do
        block_called = true
      end

      assert_equal true, block_called
    end

    test 'when NO invites are pending' do
      account = Account.new
      account.stubs(:pending_invites).returns([])
      subject = AccountPresenter.new(account, nil)
      block_called = false

      subject.when_invites_pending do
        block_called = true
      end

      assert_equal false, block_called
    end
  end

  describe '#when_show_plan_alert' do
    test 'when showing' do
      account = Account.new
      account.stubs(:plan_max_employees_reached?).returns(true)
      subject = AccountPresenter.new(account, nil)
      block_called = false

      subject.when_show_plan_alert do
        block_called = true
      end

      assert_equal true, block_called
    end

    test 'when not showing' do
      account = Account.new
      account.stubs(:plan_max_employees_reached?).returns(false)
      subject = AccountPresenter.new(account, nil)
      block_called = false

      subject.when_show_plan_alert do
        block_called = true
      end

      assert_equal false, block_called
    end
  end

  describe '#time_tracking?' do
    test 'when true' do
      account = Account.new(time_tracking: true)

      subject = AccountPresenter.new(account, nil)

      assert_equal 'Yes', subject.time_tracking?
    end

    test 'when false' do
      account = Account.new(time_tracking: false)

      subject = AccountPresenter.new(account, nil)

      assert_equal 'No', subject.time_tracking?
    end
  end

  describe '#two_factor_enabled?' do
    test 'when enabled' do
      account = Account.new(two_factor_enabled: true)

      subject = AccountPresenter.new(account, nil)

      assert_equal 'Yes', subject.two_factor_enabled?
    end

    test 'when disabled' do
      account = Account.new(two_factor_enabled: false)

      subject = AccountPresenter.new(account, nil)

      assert_equal 'No', subject.two_factor_enabled?
    end
  end

  describe '#registration_status' do
    test 'with unexpected status' do
      account = Account.new
      subject = AccountPresenter.new(account, nil)

      account.stub(:registered?, :unexpected_return_value) do
        assert_equal 'Error', subject.registration_status
      end
    end

    test 'when not registered' do
      account = Account.new
      subject = AccountPresenter.new(account, nil)

      account.stub(:registered?, false) do
        assert_equal 'Pending Registration', subject.registration_status
      end
    end

    test 'when registered' do
      account = Account.new
      subject = AccountPresenter.new(account, nil)

      account.stub(:registered?, true) do
        assert_equal 'Registered', subject.registration_status
      end
    end
  end

  test '#offices' do
    account = accounts(:oceanview_dental)
    subject = AccountPresenter.new(account, policy_stub)

    result = subject.offices

    assert_kind_of OfficesPresenter, result
  end

  test '#office_count' do
    account = accounts(:oceanview_dental)

    subject = AccountPresenter.new(account, nil)

    account.stub(:office_count, 2) do
      assert_equal 2, subject.office_count
    end
  end

  test 'paths' do
    account = accounts(:oceanview_dental)

    subject = AccountPresenter.new(account, nil)

    refute_nil subject.show_path
    refute_nil subject.edit_path
    refute_nil subject.reinvite_path
    refute_nil subject.new_plan_path
    refute_nil subject.new_office_path
    refute_nil subject.reactivate_path
    refute_nil subject.switch_account_path
  end
end
