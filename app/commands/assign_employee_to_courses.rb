class AssignEmployeeToCourses < ApplicationCommand
  def initialize(form, employee_record)
    @form = form
    @employee_record = employee_record
  end

  def call
    return broadcast(:invalid, @employee_record, @form.error_messages) if @form.invalid?

    courses = Course.find(@form.course_ids)

    new_assignments = transaction do
      courses.map do |course|
        @employee_record.assign_course!(course)
      end
    end

    if @employee_record.has_login?
      CourseMailer
        .employee_assigned_email(@employee_record, new_assignments)
        .deliver_later
    end

    broadcast(:ok, @employee_record)
  end
end
