require 'test_helper'
require_relative './deactivateable_tests'

class AccountTest < ActiveSupport::TestCase
  include DeactivateableTests

  setup do
    @subject = accounts(:oceanview_dental)
  end

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should delegate_method(:stripe_plan_id).to(:plan)
  should delegate_method(:employed).to(:employee_records).with_prefix
  should delegate_method(:suspended).to(:employee_records).with_prefix
  should delegate_method(:terminated).to(:employee_records).with_prefix

  describe 'scopes' do
    test '.registered' do
      result = Account.registered

      assert_includes result, accounts(:oceanview_dental)
      refute_includes result, accounts(:invited)
    end
  end

  describe '#office_count' do
    test 'with no offices' do
      offices = []
      account = Account.new(offices: offices)

      result = account.office_count

      assert_equal 0, result
    end

    test 'with some offices' do
      account = accounts(:oceanview_dental)

      result = account.office_count

      assert_equal account.offices.count, result
    end
  end

  describe '#states' do
    test 'with no offices' do
      account = Account.new(offices: [])

      assert_raise StandardError do
        account.states
      end
    end

    test 'with one office' do
      office = Office.new(state: 'TX')
      account = Account.new(offices: [office])

      assert_equal account.states, ['TX']
    end

    test 'with multiple offices and mixed-case' do
      office1 = Office.new(state: 'Tx')
      office2 = Office.new(state: 'aL')
      account = Account.new(offices: [office1, office2])

      result = account.states

      assert_includes result, 'AL'
      assert_includes result, 'TX'
    end
  end

  describe '#registered?' do
    test 'when not yet registered' do
      assert_equal false, accounts(:invited).registered?
    end

    test 'when registered' do
      assert_equal true, accounts(:oceanview_dental).registered?
    end
  end

  describe '#invite_accepted?' do
    test 'when invite_token is not nil/empty' do
      account = Account.new(invite_token: 'something')

      assert_equal false, account.invite_accepted?
    end

    test 'when invite token is empty' do
      account = Account.new(invite_token: '')

      assert_equal true, account.invite_accepted?
    end

    test 'when invite token is nil' do
      account = Account.new(invite_token: nil)

      assert_equal true, account.invite_accepted?
    end
  end

  test '#has_invites_remaining?' do
    plan = build(:plan, max_employees: 2)
    account = build(:account, plan: plan)
    account.stubs(:active_employee_records).returns([1])

    result = account.has_invites_remaining?

    assert_equal true, result
  end

  test '#invites_remaining' do
    plan = build(:plan, max_employees: 3)
    account = build(:account, plan: plan)
    account.stubs(:active_employee_records).returns([1])
    account.stubs(:users_with_no_employee_record).returns([1])

    result = account.invites_remaining

    assert_equal 1, result
  end

  test '#clear_invite_token!' do
    account = accounts(:oceanview_dental)

    account.clear_invite_token!

    assert_nil account.invite_token
  end

  describe '#find_course!' do
    test 'when course does not exist' do
      account = accounts(:oceanview_dental)

      assert_raise ActiveRecord::RecordNotFound do
        account.find_course!('nonexistent')
      end
    end

    test 'when course exists' do
      account = accounts(:oceanview_dental)
      course = courses(:oceanview_handbook)

      result = account.find_course!(course.id)

      assert_equal result.id, course.id
    end
  end

  describe '#assignments' do
    test 'when no assignments exist' do
      account = Account.new

      assert_empty account.assignments
    end

    test 'when assignments belong to custom course' do
      assignment = assignments(:oceanview_handbook_for_employee)
      account = accounts(:oceanview_dental)

      result = account.assignments

      assert_includes result, assignment
    end

    test 'when assignments belong to a canned courses' do
      assignment_for_account = assignments(:oceanview_canned)
      assignment_for_another_account = assignments(:brookside_canned)
      account = accounts(:oceanview_dental)

      result = account.assignments

      assert_includes result, assignment_for_account
      refute_includes result, assignment_for_another_account
    end

    test 'when employee is terminated' do
      account = accounts(:oceanview_dental)
      assignment = assignments(:oceanview_ed_expired)
      employee_records(:ed).terminated!

      result = account.assignments

      refute_includes result, assignment
    end
  end

  test '#incomplete_assignments' do
    account = Account.new
    completed = build(:assignment)
    completed.stubs(:incomplete?).returns(false)
    incomplete = build(:assignment)
    incomplete.stubs(:incomplete?).returns(true)
    assignments = [completed, incomplete]
    account.stubs(:active_assignments).returns(assignments)

    result = account.incomplete_assignments

    assert_includes result, incomplete
    refute_includes result, completed
  end

  test '#owner' do
    owner = users(:account_owner)
    account = accounts(:oceanview_dental)

    assert_equal owner, account.owner
  end

  test '#owner_email' do
    owner = users(:account_owner)
    account = accounts(:oceanview_dental)

    assert_equal owner.email, account.owner_email
  end

  test '#owner_first_name' do
    owner = users(:account_owner)
    account = accounts(:oceanview_dental)

    assert_equal owner.first_name, account.owner_first_name
  end

  test '#update_owner_password' do
    account = accounts(:oceanview_dental)
    new_password = SecureRandom.hex
    owner_mock = MiniTest::Mock.new
    owner_mock.expect(:update_password, true, [new_password])

    account.stub(:owner, owner_mock) do
      account.update_owner_password(new_password)
    end

    assert_mock owner_mock
  end

  test '#destroy_plan!' do
    account = accounts(:oceanview_dental)
    plan_mock = Minitest::Mock.new
    plan_mock.expect(:destroy!, true)

    account.stub(:plan, plan_mock) do
      account.destroy_plan!
    end

    assert_mock plan_mock
  end
end
