namespace :donedesk do
  namespace :oneoff do
    desc 'Send remaining notifications'
    task send_remaining_compliance_notifications: :environment do

      puts 'SENDING...'
      puts '------------'

      account_ids = ["c3aeeab5-2896-46c1-b13c-16dfc7f2cdaf", "e17787f7-8625-4073-9697-179715a15b5d", "ad568e8b-a1b0-4238-a784-94ea9b9fc1a9", "635da77d-a189-466c-bc93-003a547f93d6", "7ce7e930-807a-41f7-8661-a04b3bbebb57", "d68aff34-74a2-4a63-86dd-d6d50d23bcc5", "67e58fcc-f5c8-4314-8886-51ce5bb3a1a0", "d4d3f73b-4fea-4e47-a3ad-d4bc50fbc2bb", "1e3a5026-3207-4bb7-8318-df6f1dff1c9a", "74a272b0-1a28-4bb5-a087-94f5a2afe101", "dbd6e52b-e6af-4e22-9f32-e9bfedfaae82", "8e82723b-0725-4b36-8d55-45862f38ba5a", "bc17c98d-9fb3-45e0-8ec9-a7546113b3a7", "1c7bc8e8-c719-43e1-b211-9473d7c69e5d", "565e1c5f-02f2-41fb-9284-15cf90421db1", "9dec741a-e9b2-41d9-850c-6bcc82f26419", "b381fc07-ec6b-420c-aab2-cec1de05bf45", "8754dec9-8309-4e54-a387-4eb4fc9f0b06", "533b584a-9737-421f-a506-0fd2ddbbc791", "f11b5815-c421-47a9-a474-3b8f5626af10", "8b55ff46-9025-48c6-a246-f4598fe41b6f", "644949c1-a962-41c0-8613-eeb0f702ae1c", "777a64f7-0511-4227-a0d8-f76f8becc649", "89862e55-ea5b-4a20-b6df-6babe98a98a8", "097f1ff0-f3a4-41db-82a5-1b1e9136932f", "f4deca46-e3d3-4534-8186-82a371cf4a32", "ef6383a2-acbe-4659-b232-f7669fc4ee0f", "b7cdc50d-98f9-4494-be0f-66a1c686c582", "2912e0aa-606d-47db-ac16-fdacefc52373", "4a8eafd8-ce4a-442f-851d-1e874ee55597", "9e07c7d5-3603-4601-bf51-37813cee2fe6", "369c0344-eebf-4ff0-95c1-4c1cf82d4970", "dae1dd23-a620-4e66-957f-651a87486de8", "1f38cc1a-c6e2-4436-92b4-cc97f6c71bc6", "957ee4cc-1efd-4b7a-861f-469382477afd", "f1f09794-49ba-4c4d-8bc0-3aadaf7caa05", "3d4752e3-3d86-4ae5-9d2b-e9b7993a4f02", "e9326361-03b8-48e5-9271-e349b62d35d5", "54aad827-e363-4e34-b6db-13a83008e4f1", "8ecd24b9-ea9b-4e62-99f6-7c7b4f8a5428", "a21245cb-5006-4262-8ea2-68c4a298d616", "9b735b78-7610-433e-8540-1d4b2be91ad5", "f503b9b3-4fdd-48b4-9ff1-8f022564faae", "152eb9cf-b30b-42d2-a50d-46b561286c48", "b35c5d47-239f-48fe-9a41-c7a659729773"]

      Account.active.where("id NOT IN (?)", account_ids).each do |account|
        month = Date.current.strftime('%B')
        summary = AccountComplianceSummary.new(account)
        ([account.owner] + account.managers).each do |recipient_user|
          if recipient_user.send_compliance_summary_email
            ComplianceMailer
              .monthly_account_summary(recipient_user, month, summary)
              .deliver_now
          end
        end
      end

      puts 'Done.'
    end
  end
end
