# Preview all emails at http://localhost:3000/rails/mailers/course_mailer
class CourseMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/course_mailer/employee_assigned_email
  def employee_assigned_email
    employee_record = EmployeeRecord.first
    assignments = employee_record.active_assignments

    CourseMailer.employee_assigned_email(employee_record, assignments)
  end

end
