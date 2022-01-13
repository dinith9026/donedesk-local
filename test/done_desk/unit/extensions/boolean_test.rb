require 'test_helper'

class DoneDesk::BooleanTest < Minitest::Test
  def test_true_passes
    assert_equal(true, DoneDesk::Boolean === true)
  end

  def test_false_passes
    assert_equal(true, DoneDesk::Boolean === false)
  end

  def test_nil_fails
    assert_equal(false, DoneDesk::Boolean === nil)
  end

  def test_object_fails
    assert_equal(false, DoneDesk::Boolean === Object.new)
  end
end
