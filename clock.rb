require File.expand_path('../config/boot', __FILE__)
require File.expand_path('../config/environment', __FILE__)
require 'clockwork'

include Clockwork

handler do |job|
  puts "Running #{job}"
end

every(1.day, 'Account Compliance Email Notifications', at: '11:00') do
  if Date.current.day == 1
    month = Date.current.strftime('%B')
    AccountComplianceSummaryNotificationsJob.perform_later(month)
  end
end

every(1.day, 'Employee Compliance Email Notifications', at: ['Friday 11:30']) do
  date = Date.current.strftime('%m/%d/%Y')
  EmployeeComplianceSummaryNotificationsJob.perform_later(date)
end

every(1.day, 'Calculate Compliance Stats', at: '00:00') do
  Account.active.each do |account|
    CalculateComplianceStatsJob.perform_now(account.id)
  end
end

