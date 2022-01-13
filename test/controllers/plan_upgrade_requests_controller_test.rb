require 'test_helper'

class PlanUpgradeRequestsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test '#create' do
    account_owner = users(:account_owner)

    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      perform_enqueued_jobs do
        post plan_upgrade_requests_url(as: account_owner),
              { headers: { 'HTTP_REFERER' => employee_records_path } }
      end
    end
    assert_response :redirect
    assert_redirected_to employee_records_path
    refute_nil flash[:success]
  end
end
