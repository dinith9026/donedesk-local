require_relative 'boot'
require 'rails/all'
require_relative '../lib/done_desk'

DoneDesk::Config.load_environment

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DoneDesk
  MIN_PASSWORD_LENGTH = 8

  class Application < Rails::Application
    config.load_defaults 5.2

    config.autoload_paths << "#{Rails.root}/lib"
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    config.filter_parameters << :ssn
    config.session_expiration_in_minutes = 15

    config.active_job.queue_adapter = :sidekiq

    config.donedesk = DoneDesk::Config.new

    config.paperclip_defaults = {
      storage: :s3,
      s3_permissions: :private,
      s3_credentials: {
        bucket: config.donedesk.aws_s3_bucket,
        credentials: config.donedesk.aws_credentials,
        s3_region: config.donedesk.aws_region,
      }
    }

    config.stripe = {
      publishable_key: config.donedesk.stripe_publishable_key,
    }

    Stripe.api_key = DoneDesk::Secrets.stripe_secret_key

    # Do not automatically validate existence of associations
    # https://robots.thoughtbot.com/validation-database-constraint-or-both#revisting-our-users-example
    config.active_record.belongs_to_required_by_default = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

Raven.configure do |config|
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
