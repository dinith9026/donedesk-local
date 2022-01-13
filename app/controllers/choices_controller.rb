class ChoicesController < ApplicationController
  def destroy
    choice = Choice.find(params[:id])
    course = choice.question_course
    authorize choice

    choice.destroy!
    set_flash_success_and_redirect_to(course)
  end
end
