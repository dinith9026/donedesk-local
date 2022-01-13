require 'test_helper'

class TrackTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_presence_of(:courses)

  setup do
    @track = tracks(:with_3_active_courses_and_1_deactivated_course)
    @employee_record = employee_records(:with_assigned_track)
  end

  test '#assigned_tracks_for_employed_employees' do
    track = tracks(:for_oceanview)

    employee_records(:eric).suspended!
    employee_records(:mary).terminated!

    assigned_track_for_employed_employee = assigned_tracks(:ed_for_oceanview)
    assigned_track_for_suspended_employee = assigned_tracks(:eric_for_oceanview)
    assigned_track_for_terminated_employee = assigned_tracks(:mary_for_oceanview)

    result = track.assigned_tracks_for_employed_employees

    assert_includes result, assigned_track_for_employed_employee
    refute_includes result, assigned_track_for_suspended_employee
    refute_includes result, assigned_track_for_terminated_employee
  end

  describe '#completed?' do
    test 'when all assignments for active courses are NOT passed' do
      create(:exam, :passed, assignment_id: assignments(:oceanview_handbook_for_employee_with_assigned_track).id)
      create(:exam, :failed, assignment_id: assignments(:canned_for_employee_with_assigned_track).id)

      result = @track.completed?(@employee_record.id)

      assert_equal false, result
    end

    test 'when all assignments for active courses are passed and assignments for inactive courses are not passed' do
      create(:exam, :passed, assignment_id: assignments(:oceanview_handbook_for_employee_with_assigned_track).id)
      create(:exam, :passed, assignment_id: assignments(:canned_for_employee_with_assigned_track).id)
      create(:exam, :passed, assignment_id: assignments(:canned_for_texas_for_employee_with_assigned_track).id)
      create(:exam, :failed, assignment_id: assignments(:oceanview_deactivated_for_employee_with_assigned_track).id)

      result = @track.completed?(@employee_record.id)

      assert_equal true, result
    end

    test 'when all assignments for active courses are passed and assignments for inactive courses are passed' do
      create(:exam, :passed, assignment_id: assignments(:oceanview_handbook_for_employee_with_assigned_track).id)
      create(:exam, :passed, assignment_id: assignments(:canned_for_employee_with_assigned_track).id)
      create(:exam, :passed, assignment_id: assignments(:canned_for_texas_for_employee_with_assigned_track).id)
      create(:exam, :passed, assignment_id: assignments(:oceanview_deactivated_for_employee_with_assigned_track).id)

      result = @track.completed?(@employee_record.id)

      assert_equal true, result
    end
  end

  describe '#next_course_to_take' do
    test 'when none of the assignments are passed' do
      result = @track.next_course_to_take(@employee_record)

      assert_equal courses(:oceanview_handbook), result
    end

    test 'when assignment for first course is passed' do
      create(:exam, :passed, assignment_id: assignments(:oceanview_handbook_for_employee_with_assigned_track).id)

      result = @track.next_course_to_take(@employee_record)

      assert_equal courses(:canned), result
    end

    test 'when assignments for first and second course are passed' do
      create(:exam, :passed, assignment_id: assignments(:oceanview_handbook_for_employee_with_assigned_track).id)
      create(:exam, :passed, assignment_id: assignments(:canned_for_employee_with_assigned_track).id)

      result = @track.next_course_to_take(@employee_record)

      assert_equal courses(:canned_for_texas), result
    end

    test 'when assignments for first, second and third course are passed' do
      create(:exam, :passed, assignment_id: assignments(:oceanview_handbook_for_employee_with_assigned_track).id)
      create(:exam, :passed, assignment_id: assignments(:canned_for_employee_with_assigned_track).id)
      create(:exam, :passed, assignment_id: assignments(:canned_for_texas_for_employee_with_assigned_track).id)

      result = @track.next_course_to_take(@employee_record)

      assert_nil result
    end
  end
end
