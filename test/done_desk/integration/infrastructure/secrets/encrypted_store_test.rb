require 'test_helper'

class DoneDesk::EncryptSecretsTest < Minitest::AcceptanceTest
  def test_execute_expects_a_hash
    error = assert_raises(DoneDesk::ProgrammingError) do
      DoneDesk::EncryptSecrets.new.execute('')
    end

    assert_equal('Expected to receive Hash, but received String instead', error.message)
  end

  def test_execute
    subject = DoneDesk::EncryptSecrets.new

    result = subject.execute({})

    assert_equal(true, result.is_a?(String))
  end
end
