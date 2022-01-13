require 'test_helper'

class SuperAdminDashboardTest < ActiveSupport::TestCase
  test '#initialize' do
    assert SuperAdminDashboard.new
  end
end
