namespace :donedesk do
  namespace :oneoff do
    desc 'Populate office admins'
    task populate_office_admins: :environment do
      puts 'POPULATING...'
      puts '------------'

      User.account_manager.each do |account_manager|
        if account_manager.employee_record.present?
          office = account_manager.employee_record.office

          existing = OfficesUser.find_by(office_id: office.id, user_id: account_manager.id)

          if existing
            puts "#{account_manager.full_name} already assigned to #{office.name}"
          else
            OfficesUser.create!(office: office, user: account_manager)
            puts "ASSIGNED #{account_manager.full_name} to #{office.name}"
          end
        end
      end

      puts 'Done.'
    end
  end
end
