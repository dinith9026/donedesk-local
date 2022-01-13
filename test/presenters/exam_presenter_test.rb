require 'test_helper'

class ExamPresenterTest < ActiveSupport::TestCase
  subject { ExamPresenter.new(nil, nil) }
  should delegate_method(:course_title).to(:exam)
  should delegate_method(:course_description).to(:exam)
  should delegate_method(:exam_retakes_remaining).to(:assignment)

  describe '#when_must_retake_course' do
    test 'when false' do
      exam = build(:exam)
      subject = ExamPresenter.new(exam, nil)
      block_called = false

      exam.assignment.stub(:retake_course?, false) do
        subject.when_must_retake_course { block_called = true }
      end

      assert_equal false, block_called
    end

    test 'when true' do
      exam = build(:exam)
      subject = ExamPresenter.new(exam, nil)
      block_called = false

      exam.assignment.stub(:retake_course?, true) do
        subject.when_must_retake_course { block_called = true }
      end

      assert_equal true, block_called
    end
  end

  describe '#when_must_retake_exam' do
    test 'when false' do
      exam = build(:exam)
      subject = ExamPresenter.new(exam, nil)
      block_called = false

      exam.assignment.stub(:retake_course?, true) do
        subject.when_must_retake_exam { block_called = true }
      end

      assert_equal false, block_called
    end

    test 'when true' do
      exam = build(:exam)
      subject = ExamPresenter.new(exam, nil)
      block_called = false

      exam.assignment.stub(:retake_course?, false) do
        subject.when_must_retake_exam { block_called = true }
      end

      assert_equal true, block_called
    end
  end

  test '#assignment_action' do
    assignment = build(:assignment, id: SecureRandom.uuid)
    exam = build(:exam, assignment: assignment)
    subject = ExamPresenter.new(exam, nil)
    block_called = false

    result = subject.assignment_action do
      block_called = true
    end

    assert_equal true, block_called
    refute_nil result
  end

  test '#result_partial' do
    exam = build(:exam)
    subject = ExamPresenter.new(exam, nil)

    result = subject.result_partial

    assert_equal exam.to_s.downcase, result
  end

  test 'paths' do
    assignment = build(:assignment, id: SecureRandom.uuid)
    exam = build(:exam, assignment: assignment, id: SecureRandom.uuid)
    subject = ExamPresenter.new(exam, nil)

    refute_nil subject.retake_exam_path
  end
end
