require 'test_helper'

class CourseMailerTest < ActionMailer::TestCase
  describe '#employee_assigned_email' do
    test 'with one new assignment' do
      employee_record = employee_records(:ed)
      assignment = employee_record.active_assignments.first

      email = CourseMailer.employee_assigned_email(employee_record, [assignment])

      assert_emails(1) { email.deliver_now }
      assert_equal [employee_record.user_email], email.to
      assert_equal "1 New Course Assigned", email.subject
      assert_includes email.html_part.body.to_s, assignments_path
      assert_includes email.text_part.body.to_s, assignments_path
      assert_includes email.html_part.body.to_s, assignment.course_title
      assert_includes email.html_part.body.to_s, assignment.course_description
      assert_includes email.text_part.body.to_s, assignment.course_title
      assert_includes email.text_part.body.to_s, assignment.course_description
    end

    test 'with multiple new assignments' do
      employee_record = employee_records(:ed)
      assignments = employee_record.active_assignments[0..1]

      email = CourseMailer.employee_assigned_email(employee_record, assignments)

      assert_emails(1) { email.deliver_now }
      assert_equal "2 New Courses Assigned", email.subject
      assert_includes email.html_part.body.to_s, assignments_path
      assert_includes email.text_part.body.to_s, assignments_path
    end
  end
end
