require 'test_helper'

module AccountAdminsDashboardViewTests
  def self.extended(base)
    base.tests
  end

  def tests
    describe 'past due / expired assignments list' do
      test 'when an employee with an expired assignment is suspended' do
        employee_with_expired_assignment = employee_records(:ed)
        employee_with_expired_assignment.suspended!

        sign_in_with(@user)
        click_on 'Dashboard'

        within '#dashboard-past-due-or-expired-assignments' do
          refute_content employee_with_expired_assignment.full_name
        end
      end
    end
  end
end
