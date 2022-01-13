class AssignEmployeeToTracks < ApplicationCommand
  def initialize(form, employee_record)
    @form = form
    @employee_record = employee_record
  end

  def call
    return broadcast(:invalid, @employee_record, @form.error_messages) if @form.invalid?

    tracks = Track.find(@form.track_ids)

    new_assigned_tracks =
      transaction do
        tracks.map do |track|
          assigned_track = @employee_record.assigned_tracks.create!(track: track)

          track.courses.each do |course|
            Assignment.find_or_create_by!(course_id: course.id, employee_record_id: @employee_record.id)
          end

          assigned_track
        end
      end

    if @employee_record.has_login?
      TrackMailer
        .employee_assigned_email(@employee_record, new_assigned_tracks.map(&:track))
        .deliver_later
    end

    broadcast(:ok, @employee_record)
  end
end
