class AccountComplianceSummaryNotificationsJob < ApplicationJob
  queue_as :default

  def perform(month)
    Account.active.each do |account|
      summary = AccountComplianceSummary.new(account)
      ([account.owner] + account.managers).each do |recipient_user|
        if recipient_user.send_compliance_summary_email
          ComplianceMailer
            .monthly_account_summary(recipient_user, month, summary)
            .deliver_now
        end
      end
    end
  end
end
