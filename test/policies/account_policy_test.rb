require 'test_helper'

class AccountPolicyTest < PolicyTest
  describe '#index?' do
    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:index, user, nil)
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as an #{role}" do
        refute_permit(:index, users(role), nil)
      end
    end
  end

  describe '#new?' do
    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:new, user, nil)
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as an #{role}" do
        refute_permit(:new, users(role), nil)
      end
    end
  end

  describe '#create?' do
    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:create, user, nil)
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as an #{role}" do
        refute_permit(:create, users(role), nil)
      end
    end
  end

  describe '#show?' do
    test 'as a super admin' do
      user = users(:super_admin)

      assert_permit(:show, user, nil)
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as an #{role}" do
        refute_permit(:show, users(role), nil)
      end
    end
  end

  describe '#edit?' do
    describe 'as a super admin' do
      test 'when account not active' do
        user = users(:super_admin)
        account = build(:account, :deactivated)

        refute_permit(:edit, user, account)
      end

      test 'when account active' do
        user = users(:super_admin)
        account = build(:account, :active)

        assert_permit(:edit, user, account)
      end
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as an #{role}" do
        account = build(:account)

        refute_permit(:edit, users(role), account)
      end
    end
  end

  describe '#update?' do
    describe 'as a super admin' do
      test 'when account not active' do
        user = users(:super_admin)
        account = build(:account, :deactivated)

        refute_permit(:update, user, account)
      end

      test 'when account active' do
        user = users(:super_admin)
        account = build(:account, :active)

        assert_permit(:update, user, account)
      end
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as an #{role}" do
        account = build(:account)

        refute_permit(:update, users(role), account)
      end
    end
  end

  describe '#new_office?' do
    describe 'as a super admin' do
      test 'when account not active' do
        user = users(:super_admin)
        account = build(:account, :deactivated)

        refute_permit(:new_office, user, account)
      end

      test 'when account active' do
        user = users(:super_admin)
        account = build(:account, :active)

        assert_permit(:new_office, user, account)
      end
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as an #{role}" do
        account = build(:account)

        refute_permit(:new_office, users(role), account)
      end
    end
  end

  describe '#new_plan?' do
    describe 'as a super admin' do
      test 'when account not active' do
        user = users(:super_admin)
        account = build(:account, :deactivated)

        refute_permit(:new_plan, user, account)
      end

      test 'when account active' do
        user = users(:super_admin)
        account = build(:account, :active)

        assert_permit(:new_plan, user, account)
      end

      test 'when owner invite pending' do
        user = users(:super_admin)
        account = build(:account, :active, :invited)

        refute_permit(:new_plan, user, account)
      end
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as an #{role}" do
        account = build(:account)

        refute_permit(:new_plan, users(role), account)
      end
    end
  end

  describe '#create_employee_record?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      describe "as an #{role}" do
        test 'when plan limit not reached' do
          user = users(role)
          account = accounts(:oceanview_dental)
          account.stubs(:plan_max_employees_reached?).returns(false)

          assert_permit(:create_employee_record, user, account)
        end
      end
    end

    describe 'as an employee' do
      test 'with an employee record' do
        user = users(:employee)
        refute_permit(:create_employee_record, user, user.account)
      end

      test 'without an employee record' do
        user = users(:account_manager_with_no_employee_record)
        assert_permit(:create_employee_record, user, user.account)
      end
    end
  end


  describe '#reinvite?' do
    describe 'as a super admin' do
      test 'when account not active' do
        user = users(:super_admin)
        account = build(:account, :deactivated)

        refute_permit(:reinvite, user, account)
      end

      test 'when account active' do
        user = users(:super_admin)
        account = build(:account, :active, invite_token: 'something')

        assert_permit(:reinvite, user, account)
      end

      test 'when invite already accepted' do
        user = users(:super_admin)
        account = build(:account, :active, invite_token: nil)

        refute_permit(:reinvite, user, account)
      end
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as an #{role}" do
        account = build(:account)

        refute_permit(:reinvite, users(role), account)
      end
    end
  end

  describe '#deactivate?' do
    describe 'as a super admin' do
      test 'when account not active' do
        user = users(:super_admin)
        account = build(:account, :deactivated)

        refute_permit(:deactivate, user, account)
      end

      test 'when account active' do
        user = users(:super_admin)
        account = build(:account, :active)

        assert_permit(:deactivate, user, account)
      end
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as an #{role}" do
        refute_permit(:deactivate, users(role), nil)
      end
    end
  end

  describe '#reactivate?' do
    describe 'as a super admin' do
      test 'when account is already active' do
        user = users(:super_admin)
        account = build(:account, :active)

        refute_permit(:reactivate, user, account)
      end

      test 'when account is NOT already active' do
        user = users(:super_admin)
        account = build(:account, :deactivated)

        assert_permit(:reactivate, user, account)
      end
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as an #{role}" do
        refute_permit(:reactivate, users(role), nil)
      end
    end
  end
end
