require 'test_helper'

class ManageUsersTest < AcceptanceTestCase
  setup do
    @user = users(:account_manager)

    sign_in_with(@user)
    click_on 'My Profile'
  end

  test 'update' do
    new_values = valid_user_values

    click_on 'Edit'

    fill_in_and_submit_form_with(new_values)

    assert_user new_values
  end

  private

  def valid_user_values
    attributes_for(:user)
  end

  def fill_in_and_submit_form_with(values)
    fill_in 'user_email', with: values[:email]
    fill_in 'user_first_name', with: values[:first_name]
    fill_in 'user_last_name', with: values[:last_name]
    click_button 'Save'
  end

  def assert_user(values)
    assert_content values[:email]
    assert_content values[:first_name]
    assert_content values[:last_name]
  end
end
