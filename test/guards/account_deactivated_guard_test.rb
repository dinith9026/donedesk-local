require 'test_helper'

class AccountDeactivatedGuardTest < ActionDispatch::IntegrationTest
  test 'for super admin' do
    user = users(:super_admin)

    post session_url(params: auth_params_for(user))

    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'when user account is NOT deactivated' do
    user = users(:account_owner)

    post session_url(params: auth_params_for(user))

    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'when user account is deactivated' do
    user = users(:account_owner)
    user.account.deactivate!

    post session_url(params: auth_params_for(user))

    assert_response :unauthorized
  end
end
