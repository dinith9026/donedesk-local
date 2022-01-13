require 'test_helper'

class KernelTest < Minitest::Test
  class Example
    def run(example)
      hint_type(ValueObject, example)
    end
  end

  class ValueObject; end

  def test_run_returns_value
    argument = ValueObject.new
    subject = Example.new

    result = subject.run(argument)

    assert_equal(argument, result)
  end

  def test_run_raises_an_exception
    argument = Object.new
    subject = Example.new

    error = assert_raises(DoneDesk::ProgrammingError) do
      subject.run(argument)
    end

    assert_equal('Expected to receive KernelTest::ValueObject, but received Object instead', error.message)
  end
end
