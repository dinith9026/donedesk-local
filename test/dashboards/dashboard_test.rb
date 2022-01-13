require 'test_helper'

class DashboardTest < ActiveSupport::TestCase
  describe '.for' do
    test 'when role is super admin' do
      user = users(:super_admin)

      result = Dashboard.for(user)

      assert_instance_of SuperAdminDashboard, result
    end

    test 'when role is account owner' do
      user = users(:account_owner)

      result = Dashboard.for(user)

      assert_instance_of AccountOwnerDashboard, result
    end

    test 'when role is account manager' do
      user = users(:account_manager)

      result = Dashboard.for(user)

      assert_instance_of AccountManagerDashboard, result
    end

    test 'when role is employee' do
      user = users(:employee)

      result = Dashboard.for(user)

      assert_instance_of EmployeeDashboard, result
    end
  end
end
