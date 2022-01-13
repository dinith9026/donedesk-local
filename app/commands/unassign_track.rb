class UnassignTrack < ApplicationCommand
  def initialize(assigned_track)
    @assigned_track = assigned_track
  end

  def call
    transaction do
      delete_assignments
      @assigned_track.destroy!
    end

    broadcast(:ok, @assigned_track.track)
  end

  private

  def delete_assignments
    @assigned_track.courses.each do |course|
      next if course.belongs_to_another_track?(@assigned_track.track)

      assignment = find_assignment(course.id, @assigned_track.employee_record_id)
      assignment.destroy! if assignment.present?
    end
  end

  def find_assignment(course_id, employee_record_id)
    Assignment.find_by(
      employee_record_id: employee_record_id,
      course_id: course_id
    )
  end
end
