require 'test_helper'
require_relative './concerns/common_office_validation_tests'

class OfficeTest < ActiveSupport::TestCase
  setup do
    @subject = Office
  end

  include CommonOfficeValidationTests

  test '#active_assignments' do
    office = offices(:oceanview_tx)
    assignment_for_deactived_course = assignments(:oceanview_deactived_for_ed)
    active_assignment = assignments(:oceanview_handbook_for_employee)
    employee_records(:mary).terminated!
    assignment_for_terminated_employee = assignments(:oceanview_handbook_for_account_manager)
    assignment_for_other_employee = assignments(:oceanview_handbook_for_eric)

    result = office.active_assignments

    assert_includes result, active_assignment
    refute_includes result, assignment_for_deactived_course
    refute_includes result, assignment_for_terminated_employee
    refute_includes result, assignment_for_other_employee
  end
end
