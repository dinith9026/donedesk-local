require 'test_helper'

class DoneDesk::ConfigTest < Minitest::Test
  def setup
    @config = DoneDesk::Config.new(environment: ENV)
  end

  def test_aws_credentials
    refute_nil(@config.aws_credentials)
  end

  def test_aws_kms_key_id
    refute_nil(@config.aws_kms_key_id)
  end

  def test_aws_region
    refute_nil(@config.aws_region)
  end

  def test_aws_s3_bucket
    refute_nil(@config.aws_s3_bucket)
  end

  def test_exception_notification_slack_webhook
    refute_nil(@config.exception_notification_slack_webhook)
  end

  def test_execution_environment
    refute_nil(@config.execution_environment)
  end

  def test_mailgun_domain
    refute_nil(@config.mailgun_domain)
  end

  def test_stripe_publishable_key
    refute_nil(@config.stripe_publishable_key)
  end

  def test_support_email
    refute_nil(@config.support_email)
  end

  def host
    refute_nil(@config.host)
  end

  def test_hostname
    refute_nil(@config.hostname)
  end

  def test_http_basic_auth
    refute_nil(@config.http_basic_auth)
  end

  def test_talkjs_app_id
    refute_nil(@config.talkjs_app_id)
  end

  def test_missing_keys_raises_a_configuration_error
    error = assert_raises(DoneDesk::Config::EnvironmentConfigurationError) do
      subject = DoneDesk::Config.new(environment: {})
      subject.aws_credentials
    end

    assert_equal('The environment variable "AWS_IAM_ROLE" could not be found', error.message)
  end

  def test_env_file_to_load_returns_hostname_based_file_when_deployed
    ENV['DONEDESK_DEPLOYED_ENVIRONMENT'] = 'true'
    ENV['DONEDESK_HOSTNAME'] = 'hostname-to-load'

    result = DoneDesk::Config.env_file_to_load

    assert_equal('.env.hostname-to-load', result)

    ENV['DONEDESK_DEPLOYED_ENVIRONMENT'] = nil
    Dotenv.overload('.env.test')
  end

  def test_env_file_to_load_defaults_to_RAILS_ENV
    result = DoneDesk::Config.env_file_to_load

    assert_equal('.env.test', result)
  end
end
