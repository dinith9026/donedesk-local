class DeactivateTrack < ApplicationCommand
  def initialize(track)
    @track = track
  end

  def call
    transaction do
      courses = @track.courses.reject { |course| course.belongs_to_another_track?(@track) }

      courses.each do |course|
        @track.employee_records.each do |employee_record|
          assignment = Assignment.find_by(employee_record_id: employee_record.id, course_id: course.id)
          assignment.destroy! if assignment.present?
        end
      end

      @track.assigned_tracks.destroy_all
      @track.deactivate!
    end

    broadcast(:ok, @track)
  end
end
