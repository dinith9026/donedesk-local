require 'test_helper'

class TrackMailerTest < ActionMailer::TestCase
  describe '#employee_assigned_email' do
    test 'with one new track' do
      employee_record = employee_records(:ed)
      track = tracks(:for_oceanview)

      email = TrackMailer.employee_assigned_email(employee_record, [track])

      assert_emails(1) { email.deliver_now }
      assert_equal [employee_record.user_email], email.to
      assert_equal "1 New Track Assigned", email.subject
      assert_includes email.html_part.body.to_s, assignments_path
      assert_includes email.text_part.body.to_s, assignments_path
      assert_includes email.html_part.body.to_s, track.name
      assert_includes email.text_part.body.to_s, track.name
    end

    test 'with multiple new tracks' do
      employee_record = employee_records(:ed)
      tracks = [tracks(:for_oceanview), tracks(:for_oceanview2)]

      email = TrackMailer.employee_assigned_email(employee_record, tracks)

      assert_emails(1) { email.deliver_now }
      assert_equal "2 New Tracks Assigned", email.subject
      assert_includes email.html_part.body.to_s, assignments_path
      assert_includes email.text_part.body.to_s, assignments_path
    end
  end

  describe '#courses_added' do
    test 'with one new course' do
      track = tracks(:for_oceanview)
      employee_record = employee_records(:ed)
      courses = [courses(:canned)]

      email = TrackMailer.courses_added(employee_record, track, courses)

      assert_emails(1) { email.deliver_now }
      assert_equal [employee_record.user_email], email.to
      assert_equal "1 New Course Added to #{track.name} Track", email.subject
      assert_includes email.html_part.body.to_s, courses.first.title
      assert_includes email.text_part.body.to_s, courses.first.title
      assert_includes email.html_part.body.to_s, track.name
      assert_includes email.text_part.body.to_s, track.name
      assert_includes email.html_part.body.to_s, assignments_path
      assert_includes email.text_part.body.to_s, assignments_path
    end

    test 'with multiple new courses' do
      track = tracks(:for_oceanview)
      employee_record = employee_records(:ed)
      courses = [courses(:oceanview_handbook), courses(:canned)]

      email = TrackMailer.courses_added(employee_record, track, courses)

      assert_emails(1) { email.deliver_now }
      assert_equal "2 New Courses Added to #{track.name} Track", email.subject
    end
  end
end
