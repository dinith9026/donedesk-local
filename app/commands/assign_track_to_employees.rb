class AssignTrackToEmployees < ApplicationCommand
  def initialize(track, form)
    @track = track
    @form = form
  end

  def call
    return broadcast(:invalid, @track, @form.error_messages) if @form.invalid?

    transaction do
      EmployeeRecord.find(@form.employee_record_ids).each do |employee_record|
        AssignedTrack.create!(track_id: @track.id, employee_record_id: employee_record.id)

        assignments = @track.courses.map do |course|
          Assignment.find_or_create_by!(course_id: course.id, employee_record_id: employee_record.id)
        end.flatten

        if employee_record.has_login?
          TrackMailer.employee_assigned_email(employee_record, [@track]).deliver_later
        end
      end
    end

    broadcast(:ok, @track)
  end
end
