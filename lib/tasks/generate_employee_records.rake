namespace :donedesk do
  namespace :oneoff do
    desc 'Generate employee records'
    task :generate_employee_records, [:account_id] => :environment do |task, args|
      raise 'Do not run in production!' if Rails.env.production?

      require 'factory_bot'

      puts 'GENERATING...'
      puts '------------'

      account_id = args[:account_id]
      account = Account.find(account_id)

      file = File.open(Rails.root.join('test', 'fixtures', 'test.pdf'))

      ActiveRecord::Base.transaction do
        500.times do |i|
          office = account.offices.sample
          user = FactoryGirl.create(:user, account_id: account_id)
          document_group = account.document_groups.first
          employee_record = FactoryGirl.create(:employee_record, user: user, office: office, document_group: document_group)

          puts "Created #{employee_record.full_name}"

          document_group.document_types.each do |document_type|
            employee_record.documents.create!(document_type: document_type, file: file)
          end

          canned_course = Course.canned.first
          assignment = employee_record.assignments.create!(course: canned_course)
          if i.even?
            Exam.create!(assignment: assignment, passed: [true, false].sample)
          end
        end

        puts 'Done.'
      end
    end
  end
end
