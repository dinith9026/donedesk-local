namespace :donedesk do
  desc 'Manually run the employee compliance summary notifications job'
  task send_employee_compliance_summary_notifications: :environment do
    date = Date.current.strftime('%m/%d/%Y')
    EmployeeComplianceSummaryNotificationsJob.perform_now(date)
  end
end
