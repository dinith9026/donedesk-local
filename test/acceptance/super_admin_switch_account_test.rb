require 'test_helper'

class SuperAdminSwitchAccountsTest < AcceptanceTestCase
  setup do
    @account = accounts(:oceanview_dental)
    @another_account = accounts(:brookside_dental)
  end

  test 'when user is a super admin' do
    sign_in_with(users(:super_admin))

    fill_in_and_submit_form_with({ name: @account.name })
    assert_content @account.offices.first.name

    fill_in_and_submit_form_with({ name: @another_account.name })
    assert_content @another_account.offices.first.name
  end

  test 'when user is NOT a super admin' do
    sign_in_with(users(:account_owner))

    refute_content @another_account.name
  end

  private

  def fill_in_and_submit_form_with(values)
    within '#current-account-form' do
      fill_in 'current_account_name', with: values[:name]
      click_on 'Go'
    end
  end
end
