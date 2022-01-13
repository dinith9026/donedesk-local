require 'dotenv'

class DoneDesk::Config
  def initialize(environment: ENV)
    @environment = environment
  end

  def aws_credentials
    Aws::AssumeRoleCredentials.new(
      client: Aws::STS::Client.new,
      role_arn: fetch('AWS_IAM_ROLE'),
      role_session_name: 'Done-Desk'
    )
  end

  def aws_s3_bucket
    fetch('AWS_S3_BUCKET')
  end

  def aws_kms_key_id
    fetch('AWS_KMS_KEY_ID')
  end

  def aws_region
    fetch('AWS_REGION')
  end

  def exception_notification_slack_webhook
    fetch('EXCEPTION_NOTIFICATION_SLACK_WEBHOOK')
  end

  def execution_environment
    fetch('RAILS_ENV')
  end

  def mailgun_domain
    fetch('MAILGUN_DOMAIN')
  end

  def stripe_publishable_key
    fetch('STRIPE_PUBLISHABLE_KEY')
  end

  def support_email
    fetch('SUPPORT_EMAIL')
  end

  def host
    fetch('HOST')
  end

  def hostname
    fetch('DONEDESK_HOSTNAME')
  end

  def http_basic_auth
    fetch('HTTP_BASIC_AUTH')
  end

  def talkjs_app_id
    fetch('TALKJS_APP_ID')
  end

  def self.load_environment
    Dotenv.overload(env_file_to_load)
    Dotenv.load('.aws-credentials')
  end

  def self.env_file_to_load
    if ENV.fetch("DONEDESK_DEPLOYED_ENVIRONMENT", false) == "true"
      extension = ENV.fetch('DONEDESK_HOSTNAME')
    else
      extension = ENV.fetch('RAILS_ENV')
    end

    ".env.#{extension}"
  end

  class EnvironmentConfigurationError < DoneDesk::ProgrammingError; end

  private

  def fetch(key_name)
    begin
      @environment.fetch(key_name)
    rescue KeyError
      raise EnvironmentConfigurationError.new("The environment variable \"#{key_name}\" could not be found")
    end
  end
end
