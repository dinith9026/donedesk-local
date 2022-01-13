require 'test_helper'

class EmployeeComplianceSummaryNotificationsJobTest < ActiveJob::TestCase
  test '#perform' do
    recipient_count = EmployeeRecord.employed.with_active_account.select do |employee_record|
      summary = EmployeeComplianceSummary.new(employee_record)
      employee_record.send_compliance_summary_email?(summary)
    end.count

    assert_difference 'ActionMailer::Base.deliveries.size', recipient_count do
      EmployeeComplianceSummaryNotificationsJob.perform_now('2019-01-01')
    end
  end
end
