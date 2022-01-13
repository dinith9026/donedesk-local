require 'test_helper'

class ExamFormTest < ActiveSupport::TestCase
  describe 'validations' do
    test 'when not all questions have been answered' do
      assignment = assignments(:oceanview_handbook_for_employee)
      answers = [ ExamAnswer.new(nil, nil) ]
      subject = ExamForm.new(answers: answers).with_context(assignment: assignment)

      subject.valid?

      assert_includes subject.errors[:base], "You must answer every question"
    end
  end

  describe '#answer_for' do
    test 'when no answers exist' do
      result = ExamForm.new.answer_for('foo')

      assert_nil result
    end

    test 'when answer is not found' do
      answers = [
        ExamAnswer.new(SecureRandom.uuid, SecureRandom.uuid),
      ]
      subject = ExamForm.new(answers: answers)

      result = subject.answer_for('non-existent')

      assert_nil result
    end

    test 'when answers exists' do
      question_id = SecureRandom.uuid
      choice_id = SecureRandom.uuid
      answers = [
        ExamAnswer.new(question_id, choice_id),
        ExamAnswer.new(SecureRandom.uuid, SecureRandom.uuid),
      ]
      subject = ExamForm.new(answers: answers)

      result = subject.answer_for(question_id)

      assert_equal choice_id, result
    end
  end

  test '#questions' do
    assignment = assignments(:oceanview_handbook_for_employee)
    subject = ExamForm.new.with_context(assignment: assignment)

    assert_equal subject.questions, assignment.course_questions
  end

  test '#course_title' do
    assignment = assignments(:oceanview_handbook_for_employee)
    subject = ExamForm.new.with_context(assignment: assignment)

    assert_equal subject.course_title, assignment.course_title
  end

  test '#course_description' do
    assignment = assignments(:oceanview_handbook_for_employee)
    subject = ExamForm.new.with_context(assignment: assignment)

    assert_equal subject.course_title, assignment.course_title
  end

  test '#form_path' do
    assignment_stub = Struct.new(:id).new(1)
    subject = ExamForm.new.with_context(assignment: assignment_stub)

    refute_nil subject.form_path
  end
end
