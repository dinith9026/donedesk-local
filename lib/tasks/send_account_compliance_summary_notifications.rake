namespace :donedesk do
  desc 'Manually run the account compliance summary notifications job'
  task send_account_compliance_summary_notifications: :environment do
    month = Date.current.strftime('%B')
    AccountComplianceSummaryNotificationsJob.perform_now(month)
  end
end
