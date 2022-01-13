require 'done_desk'

namespace :secrets do
  desc "Fetch and list all secrets"
  task :fetch do
    puts DoneDesk::Secrets.instance.all_secrets
  end
end
