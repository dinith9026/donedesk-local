require 'aws-sdk'
require 'json'

class DoneDesk::DecryptSecrets
  def initialize(config: DoneDesk::Config.new)
    @config = config

    @client = Aws::KMS::Client.new(
      credentials: config.aws_credentials
    )
  end

  def execute(ciphertext_blob)
    hint_type(String, ciphertext_blob)

    JSON.parse(@client.decrypt(ciphertext_blob: ciphertext_blob, encryption_context: {
      "DoneDesk::Secrets Environment" => @config.hostname,
    }).plaintext)
  end
end
