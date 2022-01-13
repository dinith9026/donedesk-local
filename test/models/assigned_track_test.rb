require 'test_helper'

class AssignedTrackTest < ActiveSupport::TestCase
  setup do
    account = accounts(:oceanview_dental)
    employee_record = employee_records(:ed)

    active_course1 = create(:course, :with_question, account: account)
    active_course2 = create(:course, :with_question, account: account)
    deactivated_course = create(:course, :with_question, :deactivated, account: account)

    track = create(
      :track,
      account: account,
      courses: [active_course1, active_course2, deactivated_course]
    )
    @assigned_track = create(:assigned_track, track: track, employee_record: employee_record)

    @assignment_for_active_course1 = create(:assignment, course: active_course1, employee_record: employee_record)
    @assignment_for_active_course2 = create(:assignment, course: active_course2, employee_record: employee_record)
    @assignment_for_deactivated_course = create(
      :assignment,
      course: deactivated_course,
      employee_record: employee_record
    )
  end

  describe '#progress' do
    test '0% progress with one passed deactivated course' do
      create(:exam, :passed, assignment_id: @assignment_for_deactivated_course.id)

      assert_equal 0, @assigned_track.progress
    end

    test '0% progress' do
      assert_equal 0, @assigned_track.progress
    end

    test '50% progress' do
      create(:exam, :passed, assignment_id: @assignment_for_active_course1.id)

      assert_equal 50, @assigned_track.progress
    end

    test '100% progress' do
      create(:exam, :passed, assignment_id: @assignment_for_active_course1.id)
      create(:exam, :passed, assignment_id: @assignment_for_active_course2.id)

      assert_equal 100, @assigned_track.progress
    end
  end
end
