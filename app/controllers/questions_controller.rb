class QuestionsController < ApplicationController
  def new
    @course = find_course!
    authorize @course, :new_question?
    @form = QuestionForm.new
  end

  def create
    @course = find_course!
    authorize @course, :new_question?
    @form = QuestionForm.from_params(question_params, course_id: @course.id)

    CreateQuestionWithChoices.call(@form) do
      on(:ok) do |question|
        flash[:success] = 'Success!'
        redirect_to course_path(question.course)
      end
      on(:invalid) do
        flash[:error] = 'Please correct the errors below!'
        render :new
      end
    end
  end

  def edit
    @question = Question.find(params[:id])
    @course = @question.course
    authorize @course, :edit_question?
    @form = QuestionForm.from_model(@question)
  end

  def update
    @question = Question.find(params[:id])
    @course = @question.course
    authorize @course, :update_question?
    @form = QuestionForm.from_model(@question)
    @form.attributes = params_for_update

    UpdateQuestionWithChoices.call(@form, @question) do
      on(:ok)      { |course| set_flash_success_and_redirect_to(course) }
      on(:invalid) { set_flash_error_and_render(:edit) }
    end
  end


  def destroy
    question = Question.find(params[:id])
    authorize question.course, :destroy_question?

    DestroyQuestion.call(question) do
      on(:ok) { |course| set_flash_success_and_redirect_to(course) }
      on(:error_at_least_one_question) do |course|
        set_flash_error_and_redirect_to(course, 'An assigned course must have at least one question.')
      end
    end
  end

  private

  def question_params
    params.require(:question)
          .permit(:text, choices: [:answer, :is_correct])
  end

  def choices_params
    choices = []

    question_params[:choices].each_pair do |i, choice|
      choices << {
        answer: choice[:answer],
        is_correct: choice[:is_correct].presence || false
      }
    end

    choices
  end

  def params_for_update
    {
      text: question_params[:text],
      choices: choices_params
    }
  end

  def find_course!
    current_account.find_course!(params[:course_id])
  end
end
