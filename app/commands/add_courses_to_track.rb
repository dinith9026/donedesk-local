class AddCoursesToTrack < ApplicationCommand
  def initialize(track, courses, notify_employees)
    @track = track
    @courses = courses
    @notify_employees = notify_employees
  end

  def call
    transaction do
      @track.courses << @courses
      @track.save!

      @courses.each do |course|
        @track.employee_records.each do |employee_record|
          Assignment.find_or_create_by!(employee_record_id: employee_record.id, course_id: course.id)
        end
      end

      if @notify_employees
        @track.employee_records.employed.each do |employee_record|
          TrackMailer.courses_added(employee_record, @track, @courses).deliver_later if employee_record.has_login?
        end
      end
    end

    broadcast(:ok, @track)
  end
end
