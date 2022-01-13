namespace :donedesk do
  namespace :oneoff do
    desc 'Populate user tracking fields from Intercom data'
    task :populate_user_tracking_fields, [:dry_run] => :environment do |task, args|
      puts 'POPULATING...'
      puts '------------'

      if args[:dry_run].present?
        puts 'DRY RUN'
      end

      intercom = Intercom::Client.new(token: DoneDesk::Secrets.intercom_access_token)

      User.all.each do |user|
        result = intercom.users.find(email: user.email)

        intercom_user = result.users.find do |u|
          u["referrer"]&.include?("app.donedesk.com")
        end

        if intercom_user
          if args[:dry_run].blank?
            user.update!(
              sign_in_count: intercom_user['session_count'],
              last_sign_in_at: Time.at(intercom_user['last_request_at']).to_datetime
            )
          end

          puts "UPDATED #{user.email} "
        else
          puts "#{user.email} not found"
        end
      end

      puts 'Done.'
    end
  end
end
