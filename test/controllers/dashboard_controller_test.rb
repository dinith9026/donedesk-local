require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  describe '#show' do
    [:super_admin, :account_owner, :account_manager, :employee].each do |role|
      test "for #{role}" do
        user = users(role)

        get dashboard_url(as: user)

        assert_response :success
        assert_template "dashboard/#{role}/show"
      end
    end
  end
end
