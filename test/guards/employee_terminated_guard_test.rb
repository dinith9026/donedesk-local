require 'test_helper'

class EmployeeTerminatedGuardTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:employee)
  end

  test 'when employee is NOT terminated' do
    post session_url(params: auth_params_for(@user))

    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'when employee is terminated' do
    @user.employee_record.terminated!

    post session_url(params: auth_params_for(@user))

    assert_response :unauthorized
  end
end
