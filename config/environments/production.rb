Rails.application.configure do

  config.action_controller.perform_caching = true
  config.action_mailer.default_url_options = { protocol: 'https', host: config.donedesk.host }
  config.action_mailer.asset_host = "https://#{config.donedesk.host}"
  config.action_mailer.delivery_method = :mailgun
  config.action_mailer.perform_caching = false
  config.active_record.dump_schema_after_migration = false
  config.active_storage.service = :local
  config.active_support.deprecation = :notify
  config.assets.compile = false
  config.assets.digest = true
  config.assets.js_compressor = :uglifier
  config.cache_classes = true
  config.consider_all_requests_local = false
  config.eager_load = true
  config.force_ssl = true
  config.i18n.fallbacks = [I18n.default_locale]
  config.log_level = :debug
  config.log_tags = [ :request_id ]
  config.logger = Logger.new(STDOUT)
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Logstash.new
  config.public_file_server.enabled = true

  config.action_mailer.mailgun_settings = {
    api_key: DoneDesk::Secrets.mailgun_api_key,
    domain: DoneDesk::Config.new.mailgun_domain,
  }

  config.middleware.use ExceptionNotification::Rack, slack: {
    webhook_url: DoneDesk::Secrets.exception_notification_slack_webhook,
    additional_parameters: { mrkdwn: true }
  }

end
