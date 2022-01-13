require 'test_helper'

class ListPendingEmployeeRecordsForAccountTest < ActiveSupport::TestCase
  test 'when pending records exist' do
    account = create(:account)
    another_account = create(:account)
    office = account.offices.first
    document_group = create_employee_document_group_for(account)
    employee_user_with_invite = create(:user, :employee, account: account, confirmation_token: 'token')
    employee_user_without_invite = create(:user, :employee, account: account, confirmation_token: nil)
    manager_user = create(:user, :account_manager, account: account, confirmation_token: 'token')
    user_with_employee_record = create(:user, :employee, account: account)
    create(:employee_record, user: user_with_employee_record, office: office, document_group: document_group)

    result = ListPendingEmployeeRecordsForAccount.new(account.id).query

    assert_equal 1, result.count
    assert_includes result, employee_user_without_invite
    refute_includes result, manager_user
    refute_includes result, employee_user_with_invite
    refute_includes result, account.owner
    refute_includes result, another_account.owner
    refute_includes result, user_with_employee_record
  end
end
