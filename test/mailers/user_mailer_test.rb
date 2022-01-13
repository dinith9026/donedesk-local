require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  describe '#employee_invite_email' do
    test 'with employee record' do
      employee_user = users(:employee)
      employee_user.confirmation_token = 'foo'
      edit_pw_link = edit_user_password_path(
        employee_user,
        token: employee_user.confirmation_token)

      email = UserMailer.employee_invite_email(employee_user)

      assert_emails(1) { email.deliver_now }
      assert_equal [employee_user.email], email.to
      assert_equal "Invite: #{employee_user.account_name} DoneDesk", email.subject
      assert_includes email.html_part.body.to_s, edit_pw_link
      assert_includes email.text_part.body.to_s, edit_pw_link

      employee_user.employee_record.assigned_tracks.each do |assigned_track|
        assert_includes email.html_part.body.to_s, assigned_track.track_name
        assert_includes email.text_part.body.to_s, assigned_track.track_name
        assert_includes email.html_part.body.to_s, assignments_path
        assert_includes email.text_part.body.to_s, assignments_path
      end
    end

    test 'with NO employee record' do
      employee_user = users(:employee_with_no_employee_record)
      employee_user.confirmation_token = 'foo'

      email = UserMailer.employee_invite_email(employee_user)

      assert_emails(1) { email.deliver_now }
    end
  end
end
