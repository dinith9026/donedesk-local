require 'test_helper'

class JobsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @account_owner = users(:account_owner)
  end

  describe '#create' do
    it_requires_authenticated_user { post jobs_url }

    test 'when job is invalid' do
      post jobs_url(as: @account_owner, params: { job: 'invalid' })
      assert_redirects_with_flash_error(dashboard_path)
    end

    test 'when job is valid' do
      assert_enqueued_with(job: CalculateComplianceStatsJob) do
        post jobs_url(as: @account_owner, params: { job: 'calculate_compliance_stats' })
      end
      assert_redirects_with_flash_success(dashboard_path)
    end
  end
end
