require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test '#update' do
    user = users(:employee)
    settings_params = { send_compliance_summary_email: true }

    put settings_url(as: user), params: { settings: settings_params }

    assert_response :no_content
    assert_equal true, user.reload.send_compliance_summary_email
  end
end
