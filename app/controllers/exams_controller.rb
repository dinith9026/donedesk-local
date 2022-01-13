class ExamsController < ApplicationController
  def new
    assignment = find_assignment
    @form = ExamForm.new.with_context(assignment: assignment)
    authorize assignment, :take_exam?
  end

  def create
    assignment = find_assignment
    authorize assignment, :take_exam?
    @form = ExamForm
            .new(answers: answers_from_params)
            .with_context(assignment: assignment)

    GradeExam.call(@form, assignment) do
      on(:ok)      { |exam| redirect_to(exam) }
      on(:invalid) { |exam| set_flash_error_and_render(:new) }
    end
  end

  def show
    exam = find_exam
    authorize exam
    @exam_presenter = ExamPresenter.new(exam, policy(exam))
  end

  private

  def find_exam
    FindExamForAccount.new(current_account, params[:id]).query
  end

  def find_assignment
    FindAssignmentForAccount.new(current_account, params[:assignment_id]).query
  end

  def exam_params
    params.require(:exam).permit(answers: [:question_id, :choice_id])
  end

  def answers_from_params
    ExamAnswers.from_params(exam_params[:answers])
  end
end
