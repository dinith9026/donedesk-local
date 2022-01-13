require 'test_helper'

class AccountCourseTest < ActiveSupport::TestCase
  test '#assignments' do
    account = accounts(:oceanview_dental)
    course = courses(:canned)
    assignment_for_oceanview_employee = assignments(:oceanview_canned)
    assignment_for_brookside_employee = assignments(:brookside_canned)

    result = AccountCourse.new(account, course).assignments

    assert_includes result, assignment_for_oceanview_employee
    refute_includes result, assignment_for_brookside_employee
  end

  test '#passed_assignments' do
    account = accounts(:oceanview_dental)
    course = courses(:canned)
    incomplete_assignment_for_oceanview_employee = assignments(:oceanview_canned_for_eric)
    passed_assignment_for_oceanview_employee = assignments(:oceanview_canned)
    assignment_for_brookside_employee = assignments(:brookside_canned)

    result = AccountCourse.new(account, course).passed_assignments

    assert_includes result, passed_assignment_for_oceanview_employee
    refute_includes result, incomplete_assignment_for_oceanview_employee
    refute_includes result, assignment_for_brookside_employee
  end

  describe '#unassigned_employees' do
    test 'when course is not required by any state' do
      account = accounts(:oceanview_dental)
      course = courses(:canned_no_states)
      unassigned_employee = employee_records(:ed)

      result = AccountCourse.new(account, course).unassigned_employees

      assert_includes result, unassigned_employee
    end

    test 'when course is required for a state' do
      account = accounts(:oceanview_dental)
      course = courses(:canned_for_texas)
      assigned_in_tx_office = employee_records(:mary)
      unassigned_in_tx_office = employee_records(:ed)
      unassigned_in_oh_office = employee_records(:eric)
      unassigned_employee_from_another_account_with_office_in_tx = employee_records(:ellen)

      result = AccountCourse.new(account, course).unassigned_employees

      assert_includes result, unassigned_in_tx_office
      refute_includes result, assigned_in_tx_office
      refute_includes result, unassigned_in_oh_office
      refute_includes result, unassigned_employee_from_another_account_with_office_in_tx
    end
  end
end
