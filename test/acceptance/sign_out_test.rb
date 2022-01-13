require 'test_helper'

class SignOutTest < AcceptanceTestCase
  test 'successful' do
    user = users(:account_owner)

    sign_in_with(user)

    click_on 'Sign out'

    assert_content 'Sign in'
  end
end
