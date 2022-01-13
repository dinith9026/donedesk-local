require 'test_helper'
require_relative './account_admins_dashboard_view_tests'

class AccountManagerDashboardViewTest < AcceptanceTestCase
  setup do
    @user = users(:account_manager)
  end

  extend AccountAdminsDashboardViewTests

  test 'when no employee record exist yet' do
    account = accounts(:oceanview_dental)
    account_manager = create(:user, :account_manager, account_id: account.id)

    sign_in_with(account_manager)
    click_on 'Dashboard'

    assert_content 'New Employee Record'
  end

  test 'when employee record exists' do
    account = accounts(:oceanview_dental)
    account_manager = create(:user, :account_manager, account_id: account.id)
    create(
      :employee_record,
      user_id: account_manager.id,
      document_group: account.document_groups.first,
      office: account.offices.first
    )

    sign_in_with(account_manager)
    click_on 'Dashboard'

    assert_content 'Document Compliance'
    assert_content 'Training Compliance'
  end
end
