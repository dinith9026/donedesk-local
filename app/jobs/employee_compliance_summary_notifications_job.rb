class EmployeeComplianceSummaryNotificationsJob < ApplicationJob
  queue_as :default

  def perform(date)
    EmployeeRecord.employed.with_active_account.each do |employee_record|
      summary = EmployeeComplianceSummary.new(employee_record)
      if employee_record.send_compliance_summary_email?(summary)
        ComplianceMailer.weekly_employee_summary(
          employee_record.user,
          date,
          summary
        ).deliver_now
      end
    end
  end
end
