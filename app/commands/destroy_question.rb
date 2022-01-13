class DestroyQuestion < ApplicationCommand
  def initialize(question)
    @question = question
  end

  def call
    course = @question.course

    if course.questions.size == 1 && course.assignments.any?
      broadcast(:error_at_least_one_question, course)
    else
      @question.destroy
      broadcast(:ok, course)
    end
  end
end
