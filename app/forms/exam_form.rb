class ExamForm < ApplicationForm
  attribute :answers, Array[ExamAnswer]

  validate :all_questions_answered

  def answer_for(question_id)
    return unless answers.any?

    answer = answers.find { |a| a.question_id == question_id }

    answer&.choice_id
  end

  def form_path
    assignment_exams_path(context.assignment)
  end

  def questions
    context.assignment.course_questions
  end

  def course_title
    context.assignment.course_title
  end

  def course_description
    context.assignment.course_description
  end

  private

  def all_questions_answered
    if any_blank_answers?
      errors.add(:base, "You must answer every question")
    end
  end

  def any_blank_answers?
    answers.any? { |a| a.choice_id.to_s.empty? }
  end
end
