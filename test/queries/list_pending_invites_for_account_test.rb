require 'test_helper'

class ListPendingInvitesForAccountTest < ActiveSupport::TestCase
  test 'when pending invites exist' do
    account = create(:account)
    office = account.offices.first
    other_account = create(:account)
    other_office = other_account.offices.first
    document_group = create_employee_document_group_for(account)

    suspended_employee = create(:user, :employee, account: account, confirmation_token: 'token')
    terminated_employee = create(:user, :employee, account: account, confirmation_token: 'token')

    employee_with_token_with_emp_rec = create(:user, :employee, account: account, confirmation_token: 'token')
    employee_with_token_without_emp_rec = create(:user, :employee, account: account, confirmation_token: 'token')

    employee_with_token_with_emp_rec_signed_in = create(:user, :employee, account: account, confirmation_token: 'token', last_sign_in_at: 1.day.ago)
    employee_with_token_without_emp_rec_not_signed_in = create(:user, :employee, account: account, confirmation_token: 'token', last_sign_in_at: nil)

    employee_without_token_with_emp_rec = create(:user, :employee, account: account, confirmation_token: nil)
    employee_without_token_without_emp_rec = create(:user, :employee, account: account, confirmation_token: nil)

    other_employee_with_token_with_emp_rec = create(:user, :employee, account: other_account, confirmation_token: 'token')
    other_employee_with_token_without_emp_rec = create(:user, :employee, account: other_account, confirmation_token: 'token')

    other_employee_without_token_with_emp_rec = create(:user, :employee, account: other_account, confirmation_token: nil)
    other_employee_without_token_without_emp_rec = create(:user, :employee, account: other_account, confirmation_token: nil)

    account.owner.update!(confirmation_token: 'token')

    create(:employee_record, user: suspended_employee, office: office, status: EmployeeRecord.statuses[:suspended], document_group: document_group)
    create(:employee_record, user: terminated_employee, office: office, status: EmployeeRecord.statuses[:terminated], document_group: document_group)
    create(:employee_record, user: employee_with_token_with_emp_rec, office: office, document_group: document_group)
    create(:employee_record, user: employee_without_token_with_emp_rec, office: office, document_group: document_group)
    create(:employee_record, user: other_employee_with_token_with_emp_rec, office: other_office, document_group: document_group)
    create(:employee_record, user: other_employee_without_token_with_emp_rec, office: other_office, document_group: document_group)

    result = ListPendingInvitesForAccount.new(account.id).query

    assert_equal 3, result.count
    assert_includes result, employee_with_token_with_emp_rec
    assert_includes result, employee_with_token_without_emp_rec
    assert_includes result, employee_with_token_without_emp_rec_not_signed_in
    refute_includes result, suspended_employee
    refute_includes result, terminated_employee
    refute_includes result, employee_without_token_with_emp_rec
    refute_includes result, employee_without_token_without_emp_rec
    refute_includes result, other_employee_with_token_with_emp_rec
    refute_includes result, other_employee_with_token_without_emp_rec
    refute_includes result, other_employee_without_token_with_emp_rec
    refute_includes result, other_employee_without_token_without_emp_rec
    refute_includes result, account.owner
    refute_includes result, employee_with_token_with_emp_rec_signed_in
  end
end
