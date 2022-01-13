class GradeExam < ApplicationCommand
  def initialize(form, assignment)
    @form = form
    @assignment = assignment
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    exam = transaction do
      exam = @assignment.grade_exam!(@form.answers)

      if exam.passed?
        @assignment.create_certificate!
      end

      exam
    end

    broadcast(:ok, exam)
  end
end
