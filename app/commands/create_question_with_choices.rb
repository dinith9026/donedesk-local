class CreateQuestionWithChoices < ApplicationCommand
  def initialize(form)
    @form = form
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    transaction do
      create_question
    end

    broadcast(:ok, @question)
  end

  private

  def create_question
    @question = Question.create!(question_attrs)
  end

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
