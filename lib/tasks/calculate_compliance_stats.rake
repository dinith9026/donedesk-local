namespace :donedesk do
  desc 'Migrate course material'
  task calculate_compliance_stats: :environment do
    puts 'GENERATING...'
    puts '------------'

    Account.active.each do |account|
      puts account.name
      CalculateComplianceStatsJob.perform_now(account)
    end

    puts 'Done.'
  end
end
