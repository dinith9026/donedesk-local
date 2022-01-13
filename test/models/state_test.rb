require 'test_helper'

class StateTest < ActiveSupport::TestCase
  test "sorts states alphabetically by full name" do
    state_names = State::STATES.values

    assert_equal state_names[0], "Alabama"
    assert_equal state_names[24], "Missouri"
    assert_equal state_names[49], "Wyoming"
  end

  test ".options_for_select" do
    result = State.options_for_select

    assert_equal result.first, ["Alabama", "AL"]
    assert_equal result.last, ["Wyoming", "WY"]
  end

  test ".get" do
    assert_raise(KeyError) { State.get("INVALID") }
    assert_raise(KeyError) { State.get(nil) }
    assert_equal State.get("AL"), "Alabama"
    assert_equal State.get("aL"), "Alabama"
  end

  test ".valid_code?" do
    assert_equal State.valid_code?("INVALID"), false
    assert_equal State.valid_code?(nil), false
    assert_equal State.valid_code?("AL"), true
    assert_equal State.valid_code?("aL"), true
  end
end
