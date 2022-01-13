require 'test_helper'

class DoneDesk::DecryptSecretsTest < Minitest::AcceptanceTest
  def test_execute_expects_a_hash
    error = assert_raises(DoneDesk::ProgrammingError) do
      DoneDesk::DecryptSecrets.new.execute({})
    end

    assert_equal('Expected to receive String, but received Hash instead', error.message)
  end
end
