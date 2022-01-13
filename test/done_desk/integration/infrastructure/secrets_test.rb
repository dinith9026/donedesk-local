require 'test_helper'

class DoneDesk::SecretsTest < Minitest::Test
  def test_refute_nil
    refute_nil(DoneDesk::Secrets)
  end

  def test_secrets_object_is_a_singleton
    assert_raises(NoMethodError) do
      DoneDesk::Secrets.new
    end

    assert_same(DoneDesk::Secrets.instance, DoneDesk::Secrets.instance)
  end

  def test_stripe_secret_key
    subject = DoneDesk::Secrets

    result = subject.stripe_secret_key

    refute_nil(result)
  end

  def test_mailgun_api_key
    subject = DoneDesk::Secrets

    result = subject.mailgun_api_key

    refute_nil(result)
  end

  def test_attr_encryption_key
    subject = DoneDesk::Secrets

    result = subject.attr_encryption_key

    refute_nil(result)
  end

  def test_intercom_api_secret
    subject = DoneDesk::Secrets

    result = subject.intercom_api_secret

    refute_nil(result)
  end

  def test_talkjs_secret_key
    subject = DoneDesk::Secrets

    result = subject.talkjs_secret_key

    refute_nil(result)
  end

  def test_intercom_access_token
    subject = DoneDesk::Secrets

    result = subject.intercom_access_token

    refute_nil(result)
  end

end
