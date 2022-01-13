class RemoveCourseFromTrack < ApplicationCommand
  def initialize(track, course)
    @track = track
    @course = course
  end

  def call
    transaction do
      @track.employee_records.each do |employee_record|
        next if @course.belongs_to_another_track?(@track)

        assignment = Assignment.find_by(employee_record_id: employee_record.id, course_id: @course.id)
        assignment.destroy! if assignment.present?
      end

      courses_track = CoursesTrack.find_by!(track_id: @track.id, course_id: @course.id)
      courses_track.destroy!
    end

    broadcast(:ok, @track)
  end
end
