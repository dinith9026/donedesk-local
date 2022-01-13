require 'test_helper'

class AssignmentActionTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  test '#initialize' do
    assert_raise NoMethodError do
      AssignmentAction.new
    end
  end

  describe '#action' do
    describe 'when assignment is new and course is part of a track' do
      test 'when track is complete' do
        assignment = build(:assignment, :new, id: SecureRandom.uuid)
        track_stub = Track.new
        track_stub.stubs(:next_course_to_take).returns(nil)
        track_stub.stubs(:completed?).returns(true)

        action = AssignmentAction.from_assignment(assignment, track_stub)

        refute_nil action
        assert_equal assignment_path(assignment), action.path
        assert_equal 'Take Course', action.text
      end

      test 'when track is incomplete and assignment not new (passed)' do
        assignment = build(:assignment, :passed, id: SecureRandom.uuid)
        track_stub = Track.new
        track_stub.stubs(:next_course_to_take).returns(nil)
        track_stub.stubs(:completed?).returns(false)

        action = AssignmentAction.from_assignment(assignment, track_stub)

        refute_nil action
        assert_equal assignment_path(assignment), action.path
        assert_equal 'View Material', action.text
      end

      test 'when track is incomplete and assignment new and course is next to take' do
        assignment = build(:assignment, :new, id: SecureRandom.uuid, course_id: SecureRandom.uuid)
        next_course = Course.new(id: assignment.course_id)
        track_stub = Track.new
        track_stub.stubs(:next_course_to_take).returns(next_course)
        track_stub.stubs(:completed?).returns(false)

        action = AssignmentAction.from_assignment(assignment, track_stub)

        refute_nil action
        assert_equal assignment_path(assignment), action.path
        assert_equal 'Take Course', action.text
      end

      test 'when track is incomplete and assignment new and course is NOT next to take' do
        assignment = build(:assignment, :new, id: SecureRandom.uuid, course_id: SecureRandom.uuid)
        next_course = Course.new(id: SecureRandom.uuid)
        track_stub = Track.new
        track_stub.stubs(:next_course_to_take).returns(next_course)
        track_stub.stubs(:completed?).returns(false)

        action = AssignmentAction.from_assignment(assignment, track_stub)

        refute_nil action
        assert_nil action.path
        assert_nil action.text
      end
    end

    test 'when assignment is new' do
      assignment = build(:assignment, :new, id: SecureRandom.uuid)

      action = AssignmentAction.from_assignment(assignment, nil)

      refute_nil action
      assert_equal assignment_path(assignment), action.path
      assert_equal 'Take Course', action.text
    end

    test 'when assignment is passed' do
      assignment = build(:assignment, :passed, id: SecureRandom.uuid)

      action = AssignmentAction.from_assignment(assignment, nil)

      refute_nil action
      assert_equal assignment_path(assignment), action.path
      assert_equal 'View Material', action.text
    end

    test 'when assignment is expired' do
      assignment = build(:assignment, :expired, id: SecureRandom.uuid)

      action = AssignmentAction.from_assignment(assignment, nil)

      refute_nil action
      assert_equal assignment_path(assignment), action.path
      assert_equal 'Retake Course', action.text
    end

    test 'when assignment is expiring soon' do
      assignment = build(:assignment, :expiring_soon, id: SecureRandom.uuid)

      action = AssignmentAction.from_assignment(assignment, nil)

      refute_nil action
      assert_equal assignment_path(assignment), action.path
      assert_equal 'Retake Course', action.text
    end

    test 'when assignment is failed and retakes remaining' do
      assignment = build(:assignment, :failed, with_retakes_remaining: 1, id: SecureRandom.uuid)

      action = AssignmentAction.from_assignment(assignment, nil)

      refute_nil action
      assert_equal new_assignment_exam_path(assignment), action.path
      assert_equal 'Retake Exam', action.text
    end

    test 'when assignment is failed and NO retakes remaining' do
      assignment = build(:assignment, :failed, with_retakes_remaining: 0, id: SecureRandom.uuid)

      action = AssignmentAction.from_assignment(assignment, nil)

      refute_nil action
      assert_equal assignment_path(assignment), action.path
      assert_equal 'Retake Course', action.text
    end
  end
end
