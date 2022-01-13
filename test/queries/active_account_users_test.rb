require 'test_helper'

class ActiveAccountUsersTest < ActiveSupport::TestCase
  test '#query' do
    account = accounts(:oceanview_dental)
    account_owner = users(:account_owner)
    account_manager = users(:account_manager)
    employed_employee = users(:employee)
    terminated_employee = users(:terminated_employee)
    other_employee = users(:another_employee)
    subject = ActiveAccountUsers.new(account)

    result = subject.query

    assert_includes result, account_owner, "Account Owner should be included"
    assert_includes result, account_manager, "Account Manager should be included"
    assert_includes result, employed_employee, "Employed Employee should be included"
    refute_includes result, terminated_employee, "Terminated Employee should NOT be included"
    refute_includes result, other_employee, "Employee from another account should NOT be included"
  end
end
