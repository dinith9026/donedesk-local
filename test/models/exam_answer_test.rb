require 'test_helper'

class ExamAnswerTest < ActiveSupport::TestCase
  test '#initialize' do
    assert ExamAnswer.new('foo', 'bar')
  end
end
