class CourseMailer < ApplicationMailer
  layout 'mailer'

  include ActionView::Helpers::TextHelper

  def employee_assigned_email(employee_record, new_assignments)
    @new_assignments = new_assignments
    @employee_record = employee_record

    mail(
      to: @employee_record.user_email,
      subject: "#{pluralize(@new_assignments.count, 'New Course')} Assigned")
  end
end
