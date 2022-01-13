class UpdateQuestionWithChoices < ApplicationCommand
  def initialize(form, question)
    @form = form
    @question = question
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    @question.update!(question_attrs)

    broadcast(:ok, @question.course)
  end

  private

  def question_attrs
    {
      course_id: @form.course_id,
      text: @form.text,
      choices: choices
    }
  end

  def choices
    @form.choices.map do |choice_form|
      Choice.new(choice_form.attributes)
    end
  end
end
