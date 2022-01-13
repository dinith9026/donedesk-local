namespace :donedesk do
  namespace :oneoff do
    desc 'Generate time entries'
    task :generate_time_entries, [:account_id] => :environment do |task, args|
      raise 'Do not run in production!' if Rails.env.production?

      require 'factory_bot'

      puts 'GENERATING...'
      puts '------------'

      account_id = args[:account_id]
      account = Account.find(account_id)
      office = account.offices.first

      100.times do |i|
        user = FactoryGirl.create(:user, account_id: account_id)
        employee_record = FactoryGirl.create(:employee_record, user: user, office: office)

        (2.weeks.ago.beginning_of_week.to_date..1.week.ago.end_of_week.to_date).each do |date|
          nine_am = DateTime.new(date.year, date.month, date.day, 9, 0, 0, '-5')
          twelve_pm = DateTime.new(date.year, date.month, date.day, 12, 0, 0, '-5')
          one_pm = DateTime.new(date.year, date.month, date.day, 13, 0, 0, '-5')
          six_pm = DateTime.new(date.year, date.month, date.day, 18, 0, 0, '-5')

          FactoryGirl.create(:time_entry, :clock_in, occurred_at: nine_am, employee_record: employee_record)
          FactoryGirl.create(:time_entry, :start_break, occurred_at: twelve_pm, employee_record: employee_record)
          FactoryGirl.create(:time_entry, :end_break, occurred_at: one_pm, employee_record: employee_record)
          FactoryGirl.create(:time_entry, :clock_out, occurred_at: six_pm, employee_record: employee_record)
        end
      end

      puts 'Done.'
    end
  end
end
