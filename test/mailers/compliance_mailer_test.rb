require 'test_helper'

class ComplianceMailerTest < ActionMailer::TestCase
  describe '#monthly_account_summary' do
    test 'with expiring and expired items' do
      ed = employee_records(:ed)
      eric = employee_records(:eric)
      mary = employee_records(:mary)
      account = accounts(:oceanview_dental)
      month = 'December'
      user = users(:account_owner)

      summary = AccountComplianceSummary.new(account)

      email = ComplianceMailer.monthly_account_summary(user, month, summary)

      assert_emails(1) { email.deliver_now }
      assert_equal [user.email], email.to
      assert_equal 'Done Desk Compliance Summary for December', email.subject

      # Expired document
      assert_includes email.html_part.body.to_s, employee_record_path(ed)
      assert_includes email.text_part.body.to_s, employee_record_path(ed)
      assert_includes email.html_part.body.to_s, 'E. Employee'
      assert_includes email.text_part.body.to_s, 'E. Employee'
      assert_includes email.html_part.body.to_s, 'CPR Certification'
      assert_includes email.text_part.body.to_s, 'CPR Certification'
      assert_includes email.html_part.body.to_s, '01/01/2018'
      assert_includes email.text_part.body.to_s, '01/01/2018'

      # Expiring document
      assert_includes email.html_part.body.to_s, 'CPR Certification'

      # Expired course assignment
      assert_includes email.html_part.body.to_s, 'Course w/Expiration'

      # Expiring course assignment
      assert_includes email.html_part.body.to_s, employee_record_path(eric)
      assert_includes email.text_part.body.to_s, employee_record_path(eric)
      assert_includes email.html_part.body.to_s, 'E. Employee'
      assert_includes email.text_part.body.to_s, 'E. Employee'
      assert_includes email.html_part.body.to_s, 'Course w/Expiration'
      assert_includes email.text_part.body.to_s, 'Course w/Expiration'

      assert_includes email.html_part.body.to_s, 'Incomplete Courses'
      assert_includes email.text_part.body.to_s, 'INCOMPLETE COURSES'
      assert_includes email.html_part.body.to_s, employee_record_path(mary)
      assert_includes email.text_part.body.to_s, employee_record_path(mary)
      assert_includes email.html_part.body.to_s, 'M. Manager'
      assert_includes email.text_part.body.to_s, 'M. Manager'
      assert_includes email.html_part.body.to_s, 'Course w/Incomplete Assignment'
      assert_includes email.text_part.body.to_s, 'Course w/Incomplete Assignment'
      assert_includes email.html_part.body.to_s, '(due in 30 days)'
      assert_includes email.text_part.body.to_s, '(due in 30 days)'

    end

    test 'without any expired or expiring items' do
      user = users(:account_owner)
      month = 'December'
      summary = AccountComplianceSummary.new(Account.new)

      email = ComplianceMailer.monthly_account_summary(user, month, summary)

      assert_includes email.html_part.body.to_s, 'Congratulations! No expired documents'
      assert_includes email.html_part.body.to_s, 'Congratulations! No documents expiring soon'
      assert_includes email.html_part.body.to_s, 'Congratulations! No expired courses'
      assert_includes email.html_part.body.to_s, 'Congratulations! No courses expiring soon'
      assert_includes email.html_part.body.to_s, 'Congratulations! No incomplete courses'

      assert_includes email.text_part.body.to_s, 'Congratulations! No expired documents'
      assert_includes email.text_part.body.to_s, 'Congratulations! No documents expiring soon'
      assert_includes email.text_part.body.to_s, 'Congratulations! No expired courses'
      assert_includes email.text_part.body.to_s, 'Congratulations! No courses expiring soon'
      assert_includes email.text_part.body.to_s, 'Congratulations! No incomplete courses'
    end
  end

  describe 'weekly employee summary' do
    test 'with expiring and expired items and incomplete assignments and missing/required documents' do
      employee_record = employee_records(:ed)
      date = '2019-01-01'
      summary = EmployeeComplianceSummary.new(employee_record)

      email = ComplianceMailer.weekly_employee_summary(employee_record.user, date, summary)

      assert_emails(1) { email.deliver_now }
      assert_equal [employee_record.user.email], email.to
      assert_equal "Done Desk Compliance Summary for #{date}", email.subject

      assert_includes email.html_part.body.to_s, 'CPR Certification'
      assert_includes email.text_part.body.to_s, 'CPR Certification'
      assert_includes email.html_part.body.to_s, '01/01/2018'
      assert_includes email.text_part.body.to_s, '01/01/2018'
      assert_includes email.html_part.body.to_s, 'Course w/Expiration'
      assert_includes email.text_part.body.to_s, 'Course w/Expiration'

      summary.incomplete_course_assignments.each do |assignment|
        assert_includes email.html_part.body.to_s, assignment.course_title
        assert_includes email.text_part.body.to_s, assignment.course_title
        assert_includes email.html_part.body.to_s, assignment_path(assignment)
        assert_includes email.text_part.body.to_s, assignment_path(assignment)

        if assignment.due_date.present?
          assert_includes email.html_part.body.to_s, 'due'
          assert_includes email.text_part.body.to_s, 'due'
        end
      end

      summary.missing_required_documents.each do |document_type|
        assert_includes email.html_part.body.to_s, document_type.name
        assert_includes email.text_part.body.to_s, document_type.name
      end
    end

    test 'without any expired or expiring items or incomplete items' do
      employee_record = build(:employee_record)
      summary = EmployeeComplianceSummary.new(employee_record)

      email = ComplianceMailer.weekly_employee_summary(User.new, '2019-01-01', summary)

      assert_includes email.html_part.body.to_s, 'Congratulations! No expired documents'
      assert_includes email.html_part.body.to_s, 'Congratulations! No documents expiring soon'
      assert_includes email.html_part.body.to_s, 'Congratulations! No expired courses'
      assert_includes email.html_part.body.to_s, 'Congratulations! No courses expiring soon'
      assert_includes email.html_part.body.to_s, 'Congratulations! No incomplete courses'
      assert_includes email.html_part.body.to_s, 'Congratulations! No missing/required documents'

      assert_includes email.text_part.body.to_s, 'Congratulations! No expired documents'
      assert_includes email.text_part.body.to_s, 'Congratulations! No documents expiring soon'
      assert_includes email.text_part.body.to_s, 'Congratulations! No expired courses'
      assert_includes email.text_part.body.to_s, 'Congratulations! No incomplete courses'
      assert_includes email.text_part.body.to_s, 'Congratulations! No missing/required documents'
    end
  end
end
