require 'test_helper'

class AccountComplianceSummaryNotificationsJobTest < ActiveJob::TestCase
  test 'notifications are sent' do
    recipient_count = Account.active.sum do |account|
      ([account.owner] + account.managers).count
    end

    assert_difference 'ActionMailer::Base.deliveries.size', recipient_count do
      AccountComplianceSummaryNotificationsJob.perform_now('December')
    end
  end
end
