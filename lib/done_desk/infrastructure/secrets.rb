require 'singleton'

class DoneDesk::Secrets
  class << self
    def mailgun_api_key
      instance.fetch(:mailgun_api_key)
    end

    def stripe_secret_key
      instance.fetch(:stripe_secret_key)
    end

    def attr_encryption_key
      instance.fetch(:attr_encryption_key)
    end

    def secret_key_base
      instance.fetch(:secret_key_base)
    end

    def http_basic_auth_name
      instance.fetch(:http_basic_auth_name)
    end

    def http_basic_auth_password
      instance.fetch(:http_basic_auth_password)
    end

    def exception_notification_slack_webhook
      instance.fetch(:exception_notification_slack_webhook)
    end

    def intercom_api_secret
      instance.fetch(:intercom_api_secret)
    end

    def talkjs_secret_key
      instance.fetch(:talkjs_secret_key)
    end

    def intercom_access_token
      instance.fetch(:intercom_access_token)
    end
  end

  include Singleton

  def initialize(secrets_store: DoneDesk::EncryptedSecretsStore.new, decrypter: DoneDesk::DecryptSecrets.new)
    @secrets_store = secrets_store
    @decrypter = decrypter
    @secrets = @decrypter.execute(@secrets_store.fetch)
  end

  def fetch(secret_name, config: DoneDesk::Config.new)
    begin
      @secrets.fetch("#{secret_name}")
    rescue KeyError
      raise KeyError.new("\"#{secret_name}\" is unvailable. Set it with: `RAILS_ENV=#{config.execution_environment} rake secrets:set[#{secret_name},REPLACE_WITH_VALUE]`")
    end
  end

  def set_secret(key, value)
    @secrets = @secrets.merge({"#{key}" => value})
    @secrets_store.store(DoneDesk::EncryptSecrets.new.execute(@secrets))
  end

  def all_secrets
    @secrets
  end
end
