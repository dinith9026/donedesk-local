class TrackCoursesController < ApplicationController
  def create
    track = find_active_track
    authorize track, :add_course?
    courses = current_account.courses.active.find(track_params[:course_ids])

    AddCoursesToTrack.call(track, courses, track_params[:notify_employees].present?) do
      on(:ok) { |a_track| set_flash_success_and_redirect_to(a_track) }
    end
  end

  def update
    track = find_active_track
    authorize track, :reorder_courses?
    courses_track = CoursesTrack.find_by!(track_id: track.id, course_id: params[:id])

    courses_track.insert_at(params[:position].to_i)

    head :no_content
  end

  def destroy
    track = find_active_track
    course = current_account.find_course!(params[:id])
    authorize track, :remove_course?

    RemoveCourseFromTrack.call(track, course) do
      on(:ok) { |a_track| set_flash_success_and_redirect_to(a_track) }
    end
  end

  private

  def find_active_track
    current_account.tracks.active.includes(:courses).find(params[:track_id])
  end

  def track_params
    params.require(:track).permit(:notify_employees, course_ids: [])
  end
end
