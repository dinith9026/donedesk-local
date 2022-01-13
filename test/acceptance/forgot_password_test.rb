require 'test_helper'

class ForgotPasswordTest < AcceptanceTestCase
  setup do
    @user = users(:employee)
  end

  test 'with a valid password' do
    visit '/sign_in'
    click_on 'Forgot password?'

    fill_in 'password_email', with: @user.email
    click_on 'Submit'

    @user.reload

    visit edit_user_password_url(@user, token: @user.confirmation_token)

    fill_in 'password_reset_password', with: default_password
    click_on 'Submit'

    assert_content 'Dashboard'
  end
end
