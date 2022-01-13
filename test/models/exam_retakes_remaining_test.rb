require 'test_helper'

class ExamRetakesRemainingTest < ActiveSupport::TestCase
  describe '#calculate' do
    test 'when no exams' do
      subject = ExamRetakesRemaining.new(3, 0)

      result = subject.calculate

      assert_equal 3, result
    end

    test 'when on first exam round and max retakes is zero' do
      subject = ExamRetakesRemaining.new(0, 2)

      result = subject.calculate

      assert_equal 0, result
    end

    test 'when on first exam round and max retakes not reached' do
      subject = ExamRetakesRemaining.new(3, 2)

      result = subject.calculate

      assert_equal 1, result
    end

    test 'when on first exam round and max retakes reached' do
      subject = ExamRetakesRemaining.new(3, 3)

      result = subject.calculate

      assert_equal 3, result
    end

    test 'when on second exam round and max retakes not reached' do
      subject = ExamRetakesRemaining.new(3, 4)

      result = subject.calculate

      assert_equal 2, result
    end

    test 'when on second exam round and max retakes reached' do
      subject = ExamRetakesRemaining.new(3, 6)

      result = subject.calculate

      assert_equal 3, result
    end
  end
end
