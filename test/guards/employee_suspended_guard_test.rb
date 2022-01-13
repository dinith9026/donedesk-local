require 'test_helper'

class EmployeeSuspendedGuardTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:employee)
  end

  test 'when employee is NOT suspended' do
    post session_url(params: auth_params_for(@user))

    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'when employee is suspended' do
    @user.employee_record.suspended!

    post session_url(params: auth_params_for(@user))

    assert_response :unauthorized
  end
end
