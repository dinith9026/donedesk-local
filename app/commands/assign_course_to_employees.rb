class AssignCourseToEmployees < ApplicationCommand
  def initialize(course, form)
    @course = course
    @form = form
    @new_assignments = []
  end

  def call
    return broadcast(:invalid, @course, @form.error_messages) if @form.invalid?

    transaction do
      create_assignments
      send_notification_to_employees
    end

    broadcast(:ok)
  end

  private

  def create_assignments
    employee_records.each do |employee_record|
      @new_assignments << create_assignment_for(employee_record)
    end
  end

  def create_assignment_for(employee_record)
    Assignment.create!(course_id: @course.id, employee_record_id: employee_record.id)
  end

  def send_notification_to_employees
    @new_assignments.each do |assignment|
      if assignment.employee_record.has_login?
        CourseMailer.employee_assigned_email(assignment.employee_record, [assignment]).deliver_later
      end
    end
  end

  def employee_records
    @employee_records ||= FindEmployeeRecord.new(@form.employee_record_ids).query
  end
end
