require 'test_helper'

class ExamGradeTest < ActiveSupport::TestCase
  test 'when answers is nil' do
    assert_raises ExamGrade::EmptyAnswers do
      ExamGrade.new(nil, [], 70)
    end
  end

  test 'when answers is empty' do
    assert_raises ExamGrade::EmptyAnswers do
      ExamGrade.new([], [], 70)
    end
  end

  test 'when questions is nil' do
    assert_raises ExamGrade::EmptyQuestions do
      ExamGrade.new([1], nil, 70)
    end
  end

  test 'when questions is empty' do
    assert_raises ExamGrade::EmptyQuestions do
      ExamGrade.new([1], [], 70)
    end
  end

  test 'when passing threshold is nil' do
    assert_raises ExamGrade::InvalidPassingThreshold do
      ExamGrade.new([1], [1], nil)
    end
  end

  test 'when passing threshold is 0' do
    assert_raises ExamGrade::InvalidPassingThreshold do
      ExamGrade.new([1], [1], 0)
    end
  end

  test 'when below passing threshold' do
    questions = build_list(:question, 2, :with_choices)
    answers = [correct_answer_for(questions.first), wrong_answer_for(questions.last)]
    exam_grade = ExamGrade.new(answers, questions, 51)

    assert_equal false, exam_grade.passed?
  end

  test 'when equal to passing threshold' do
    questions = build_list(:question, 2, :with_choices)
    answers = [correct_answer_for(questions.first), wrong_answer_for(questions.last)]
    exam_grade = ExamGrade.new(answers, questions, 50)

    assert_equal true, exam_grade.passed?
  end

  test 'when above passing threshold' do
    questions = build_list(:question, 2, :with_choices)
    answers = [correct_answer_for(questions.first), wrong_answer_for(questions.last)]
    exam_grade = ExamGrade.new(answers, questions, 49)

    assert_equal true, exam_grade.passed?
  end

  private

  def correct_answer_for(question)
    ExamAnswer.new(question.id, question.correct_choice.id)
  end

  def wrong_answer_for(question)
    ExamAnswer.new(question.id, 'wrong choice')
  end
end
