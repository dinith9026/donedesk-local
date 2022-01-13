require 'aws-sdk'
require 'base64'

class DoneDesk::EncryptedSecretsStore
  SECRET_KEY = '.secrets'

  def initialize(config: DoneDesk::Config.new)
    @config = config
    @client = Aws::S3::Client.new(credentials: config.aws_credentials)
  end

  def store(data)
    @client.put_object({
      bucket: @config.aws_s3_bucket,
      body: Base64.encode64(data),
      key: SECRET_KEY
    })
  end

  def fetch
    response = @client.get_object({
      bucket: @config.aws_s3_bucket,
      key: SECRET_KEY
    })

    Base64.decode64(response.body.read)
  end
end
