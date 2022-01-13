require 'aws-sdk'
require 'json'

class DoneDesk::EncryptSecrets
  def initialize(config: DoneDesk::Config.new)
    @config = config

    @client = Aws::KMS::Client.new(
      credentials: config.aws_credentials
    )
  end

  def execute(hash)
    hint_type(Hash, hash)

    @client.encrypt(key_id: @config.aws_kms_key_id, plaintext: JSON.generate(hash), encryption_context: {
      "DoneDesk::Secrets Environment" => @config.hostname,
    }).ciphertext_blob
  end
end
