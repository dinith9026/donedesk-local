require 'test_helper'

class ExamTest < ActiveSupport::TestCase
  describe '#to_s' do
    test 'when passed' do
      exam = build(:exam, passed: true)

      assert_equal 'Passed', exam.to_s
    end

    test 'when failed' do
      exam = build(:exam, passed: false)

      assert_equal 'Failed', exam.to_s
    end
  end

  describe '#grade!' do
    class ExamGradeFailedStub
      def initialize(answers, questions, passing_threshold)
      end

      def passed?
        false
      end
    end

    class ExamGradePassedStub
      def initialize(answers, questions, passing_threshold)
      end

      def passed?
        true
      end
    end

    test 'when failed' do
      grader_stub = ExamGradeFailedStub
      exam = build(:exam, passed: nil)
      exam.stubs(:save!).returns(true)

      result = exam.grade!([], grader_stub)

      assert_equal false, result.passed?
    end

    test 'when passed' do
      grader_stub = ExamGradePassedStub
      exam = build(:exam, passed: nil)
      exam.stubs(:save!).returns(true)

      result = exam.grade!([], grader_stub)

      assert_equal true, result.passed?
    end
  end
end
