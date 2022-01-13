require 'test_helper'

class ManageAccountsTest < AcceptanceTestCase
  setup do
    @user = users(:super_admin)
    sign_in_with @user
    click_on 'Accounts'
  end

  test 'creating a new account' do
    DocumentGroupPreset.create!(
      name: 'Default for Employees',
      document_types: [
        { id: document_types(:w4).id, required: true }
      ],
      applies_to: 'employees',
      is_default: true
    )

    DocumentGroupPreset.create!(
      name: 'Default for Offices',
      document_types: [
        { id: document_types(:office_maintenance_checklist).id, required: false }
      ],
      applies_to: 'offices',
      is_default: true
    )

    user = attributes_for(:user)
    office = attributes_for(:office)
    plan = attributes_for(:plan)
    values = attributes_for(:account, user: user, office: office, plan: plan)

    click_on 'New Account'

    fill_in_and_submit_form_with(values)

    assert_content 'Success!'
    assert_content values[:name]
    assert_content values[:plan][:monthly_price]
    assert_content values[:plan][:max_employees]
  end

  test 'adding a new plan' do
    account = accounts(:oceanview_dental)
    InitializeBilling.call(account, stripe_card_token)

    new_monthly_price = account.plan_monthly_price + 1
    new_max_employees = account.plan_max_employees + 1

    within('.accounts-list') { click_on account.name }
    click_on 'New Plan'

    fill_in 'plan_monthly_price', with: new_monthly_price
    fill_in 'plan_max_employees', with: new_max_employees
    click_on 'Save'

    assert_content "$#{new_monthly_price}"
    assert_content new_max_employees
  end

  private

  def fill_in_and_submit_form_with(values)
    fill_in 'account_name', with: values[:name]
    fill_in 'account_plan_monthly_price', with: values[:plan][:monthly_price]
    fill_in 'account_plan_max_employees', with: values[:plan][:max_employees]
    fill_in 'account_user_first_name', with: values[:user][:first_name]
    fill_in 'account_user_last_name', with: values[:user][:last_name]
    fill_in 'account_user_email', with: values[:user][:email]
    fill_in 'account_office_name', with: values[:office][:name]
    fill_in 'account_office_phone', with: values[:office][:phone]
    fill_in 'account_office_street_address', with: values[:office][:street_address]
    fill_in 'account_office_address2', with: values[:office][:address2]
    fill_in 'account_office_city', with: values[:office][:city]
    select State.get(values[:office][:state]), from: 'account_office_state'
    fill_in 'account_office_zip', with: values[:office][:zip]
    click_on 'Save'
  end
end
