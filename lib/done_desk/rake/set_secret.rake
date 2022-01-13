require 'done_desk'

namespace :secrets do
  desc "Set, encrypt, and store a secret"
  task :set, [:secret_name, :secret_value] do |t, args|
    DoneDesk::Secrets.instance.set_secret(args[:secret_name], args[:secret_value])
  end
end
