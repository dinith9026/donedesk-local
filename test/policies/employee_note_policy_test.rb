require 'test_helper'

class EmployeeNotePolicyTest < PolicyTest
  describe '#index?' do
    test 'as a super admin' do
      assert_permit(:index, users(:super_admin), EmployeeNote)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        assert_permit(:index, users(role), EmployeeNote)
      end
    end

    test 'as an employee' do
      refute_permit(:index, users(:employee), EmployeeNote)
    end
  end

  describe '#new?' do
    test 'as a super admin' do
      user = users(:super_admin)
      assert_permit(:new, user, EmployeeNote)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        assert_permit(:new, users(role), EmployeeNote)
      end
    end

    test 'as an employee' do
      refute_permit(:new, users(:employee), EmployeeNote)
    end
  end

  describe '#create?' do
    test 'as a super admin' do
      assert_permit(:create, users(:super_admin), EmployeeNote)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        assert_permit(:create, users(role), EmployeeNote)
      end
    end

    test 'as an employee' do
      refute_permit(:create, users(:employee), EmployeeNote)
    end
  end
end
