require 'test_helper'

class CalculateAccountIncompleteAssignmentsTest < CommandTest
  test 'when no incomplete assignments have been calculated yet' do
    count_before = IncompleteAssignment.count
    account = accounts(:oceanview_dental)

    assert_broadcast(:ok) { CalculateAccountIncompleteAssignments.call(account) }
    assert IncompleteAssignment.count > count_before
  end

  test 'when incomplete assignments have already been calculated' do
    account = create(:account)
    user = create(:user, :employee)
    document_group = create_employee_document_group_for(account)
    employee_record = create(
      :employee_record,
      office: account.offices.first,
      document_group: document_group,
      user: user
    )
    course = courses(:canned)
    assignment = create(:assignment, employee_record: employee_record, course: course)
    IncompleteAssignment.create!(assignment: assignment, status: 'new')
    count_before = IncompleteAssignment.count

    assert_broadcast(:ok) { CalculateAccountIncompleteAssignments.call(account) }
    assert_equal count_before, IncompleteAssignment.count
  end
end
