class CalculateComplianceStatsJob < ApplicationJob
  queue_as :default

  def perform(account_id)
    account = Account.find(account_id)

    CalculateAccountComplianceStats.call(account)
    CalculateAccountMissingDocuments.call(account)
    CalculateAccountExpiredDocuments.call(account)
    CalculateAccountExpiringDocuments.call(account)
    CalculateAccountIncompleteAssignments.call(account)

    account.offices.each do |office|
      CalculateOfficeComplianceStats.call(office)
    end

    account.update!(is_calculating_compliance_stats: false)
    account.touch(:compliance_stats_last_updated_at)
  end
end
