class DoneDesk::HealthCheck

  def execute
    check_configuration
  end


  def check_configuration(config: DoneDesk::Config.new)
    {
      "DoneDesk::Config#aws_credentials" => config.aws_credentials.present?,
      "DoneDesk::Config#aws_s3_bucket" => config.aws_s3_bucket.present?,
      "DoneDesk::Config#aws_kms_key_id" => config.aws_kms_key_id.present?,
      "DoneDesk::Config#aws_region" => config.aws_region.present?,
      "DoneDesk::Config#exception_notification_slack_webhook" => config.exception_notification_slack_webhook.present?,
      "DoneDesk::Config#execution_environment" => config.execution_environment.present?,
      "ActiveRecord Connection to Postgres Established" => ActiveRecord::Base.connected?,
      "RAILS_ENV" => ENV.fetch('RAILS_ENV')
    }
  end
end
