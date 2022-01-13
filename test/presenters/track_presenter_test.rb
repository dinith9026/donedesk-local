require 'test_helper'

class TrackPresenterTest < ActiveSupport::TestCase
  subject { TrackPresenter.new(nil, nil) }

  should delegate_method(:name).to(:track)
  should delegate_method(:active?).to(:track)
  should delegate_method(:deactivated?).to(:track)
  should delegate_method(:courses).to(:track)

  test '#assigned_tracks_presenter' do
    track = tracks(:for_oceanview)
    assigned_tracks = []
    subject = TrackPresenter.new(track, policy_stub).with_context(assigned_tracks: assigned_tracks)

    result = subject.assigned_tracks_presenter

    assert_kind_of AssignedTracksPresenter, result
  end

  describe '#when_show_enabled_remove_course_btn' do
    test 'when user can remove course and track is active' do
      track_stub = Track.new
      track_stub.stubs(:active?).returns(true)
      policy_stub = TrackPolicy.new(User.new, track_stub)
      policy_stub.stubs(:remove_course?).returns(true)
      subject = TrackPresenter.new(track_stub, policy_stub)
      block_called =false

      subject.when_show_enabled_remove_course_btn { block_called = true }

      assert_equal true, block_called
    end

    test 'when user can remove course and track is deactivated' do
      track_stub = Track.new
      track_stub.stubs(:active?).returns(false)
      policy_stub = TrackPolicy.new(User.new, track_stub)
      policy_stub.stubs(:remove_course?).returns(true)
      subject = TrackPresenter.new(track_stub, policy_stub)
      block_called =false

      subject.when_show_enabled_remove_course_btn { block_called = true }

      assert_equal false, block_called
    end

    test 'when user cannot remove course and track is active' do
      track_stub = Track.new
      policy_stub = TrackPolicy.new(User.new, track_stub)
      policy_stub.stubs(:remove_course?).returns(false)
      subject = TrackPresenter.new(track_stub, policy_stub)
      block_called = false

      subject.when_show_enabled_remove_course_btn { block_called = true }

      assert_equal false, block_called
    end

    test 'when user cannot remove course and track is deactivated' do
      track_stub = Track.new
      policy_stub = TrackPolicy.new(User.new, track_stub)
      policy_stub.stubs(:remove_course?).returns(false)
      subject = TrackPresenter.new(track_stub, policy_stub)
      block_called = false

      subject.when_show_enabled_remove_course_btn { block_called = true }

      assert_equal false, block_called
    end
  end

  describe '#when_show_disabled_remove_course_btn' do
    test 'when user can remove course and track is active' do
      track_stub = Track.new
      policy_stub = TrackPolicy.new(User.new, track_stub)
      policy_stub.stubs(:remove_course?).returns(true)
      subject = TrackPresenter.new(track_stub, policy_stub)
      block_called = false

      subject.when_show_disabled_remove_course_btn { block_called = true }

      assert_equal false, block_called
    end

    test 'when user can remove course and track is deactivated' do
      track_stub = Track.new
      policy_stub = TrackPolicy.new(User.new, track_stub)
      policy_stub.stubs(:remove_course?).returns(true)
      subject = TrackPresenter.new(track_stub, policy_stub)
      block_called = false

      subject.when_show_disabled_remove_course_btn { block_called = true }

      assert_equal false, block_called
    end

    test 'when user cannot remove course and track is active' do
      track_stub = Track.new
      track_stub.stubs(:active?).returns(true)
      policy_stub = TrackPolicy.new(User.new, track_stub)
      policy_stub.stubs(:remove_course?).returns(false)
      subject = TrackPresenter.new(track_stub, policy_stub)
      block_called = false

      subject.when_show_disabled_remove_course_btn { block_called = true }

      assert_equal true, block_called
    end

    test 'when user cannot remove course and track is deactivated' do
      track_stub = Track.new
      track_stub.stubs(:active?).returns(false)
      policy_stub = TrackPolicy.new(User.new, track_stub)
      policy_stub.stubs(:remove_course?).returns(false)
      subject = TrackPresenter.new(track_stub, policy_stub)
      block_called = false

      subject.when_show_disabled_remove_course_btn { block_called = true }

      assert_equal false, block_called
    end
  end

  describe '#when_unassigned_courses_exist' do
    test 'when unassigned courses exist' do
      course_stub = Course.new
      course_stub.stubs(:assignable?).returns(true)
      subject = TrackPresenter.new(Track.new, nil).with_context(unassigned_courses: [course_stub])
      block_called = false

      subject.when_unassigned_courses_exist { block_called = true }

      assert_equal true, block_called
    end

    test 'when unassigned courses do not exist' do
      subject = TrackPresenter.new(Track.new, nil).with_context(unassigned_courses: [])
      block_called = false

      subject.when_unassigned_courses_exist { block_called = true }

      assert_equal false, block_called
    end
  end

  describe '#when_no_unassigned_courses_exist' do
    test 'when unassigned courses exist' do
      course_stub = Course.new
      course_stub.stubs(:assignable?).returns(true)
      subject = TrackPresenter.new(Track.new, nil).with_context(unassigned_courses: [course_stub])
      block_called = false

      subject.when_no_unassigned_courses_exist { block_called = true }

      assert_equal false, block_called
    end

    test 'when unassigned courses do not exist' do
      subject = TrackPresenter.new(Track.new, nil).with_context(unassigned_courses: [])
      block_called = false

      subject.when_no_unassigned_courses_exist { block_called = true }

      assert_equal true, block_called
    end
  end

  describe '#when_unassigned_employees_exist' do
    test 'when unassigned employees exist' do
      subject = TrackPresenter.new(Track.new, nil).with_context(unassigned_employees: [EmployeeRecord.new])
      block_called = false

      subject.when_unassigned_employees_exist { block_called = true }

      assert_equal true, block_called
    end

    test 'when unassigned employees do not exist' do
      subject = TrackPresenter.new(Track.new, nil).with_context(unassigned_employees: [])
      block_called = false

      subject.when_unassigned_employees_exist { block_called = true }

      assert_equal false, block_called
    end
  end

  describe '#when_no_unassigned_employees_exist' do
    test 'when unassigned employees exist' do
      subject = TrackPresenter.new(Track.new, nil).with_context(unassigned_employees: [EmployeeRecord.new])
      block_called = false

      subject.when_no_unassigned_employees_exist { block_called = true }

      assert_equal false, block_called
    end

    test 'when unassigned employees do not exist' do
      subject = TrackPresenter.new(Track.new, nil).with_context(unassigned_employees: [])
      block_called = false

      subject.when_no_unassigned_employees_exist { block_called = true }

      assert_equal true, block_called
    end
  end

  test '#created_at' do
    track = build(:track, created_at: '2020-07-08 20:11:15.178427')

    subject = TrackPresenter.new(track, policy_stub)

    assert_equal '2020-07-08  8:11 PM UTC', subject.created_at
  end

  test '#updated_at' do
    track = build(:track, updated_at: '2020-07-08 20:11:15.178427')

    subject = TrackPresenter.new(track, policy_stub)

    assert_equal '2020-07-08  8:11 PM UTC', subject.updated_at
  end

  test '#total_active_courses' do
    track = Track.new
    course1 = Course.new
    course1.stubs(:active?).returns(true)
    course2 = Course.new
    course2.stubs(:active?).returns(false)
    track.courses = [course1, course2]
    subject = TrackPresenter.new(track, nil)

    result = subject.total_active_courses

    assert_equal 1, result
  end

  test 'paths' do
    track_stub = Struct.new(:id).new(1)
    subject = TrackPresenter.new(track_stub, nil)

    refute_nil subject.show_path
    refute_nil subject.edit_path
    refute_nil subject.add_courses_path
    refute_nil subject.create_assigned_track_path
    refute_nil subject.destroy_path
    refute_nil subject.deactivate_path
    refute_nil subject.reactivate_path
  end
end
