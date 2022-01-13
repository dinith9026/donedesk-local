require 'test_helper'

class TrackCoursesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @account = accounts(:oceanview_dental)
    @active_track = tracks(:for_oceanview)
    @active_track_course = courses(:oceanview_handbook)
    @deactivated_track = tracks(:for_oceanview_deactivated)
    @another_active_track = tracks(:for_brookside)
  end

  describe '#create' do
    it_requires_authenticated_user { post track_courses_url(@active_track) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when track does NOT belong to their account' do
          assert_no_difference 'CoursesTrack.count' do
            post track_courses_url(as: users(role), track_id: @another_active_track.id)
          end
          assert_redirects_with_not_found_error
        end

        test 'when track is deactivated' do
          assert_no_difference 'CoursesTrack.count' do
            post track_courses_url(as: users(role), track_id: @deactivated_track.id)
          end
          assert_redirects_with_not_found_error
        end

        test 'when course id does NOT belong to their account' do
          invalid_course_ids = [courses(:brookside_handbook).id]

          assert_no_difference 'CoursesTrack.count' do
            post track_courses_url(as: users(role), track_id: @active_track.id),
              params: { track: { course_ids: invalid_course_ids } }
          end
          assert_redirects_with_not_found_error
        end

        test 'when course is deactivated' do
          invalid_course_ids = [courses(:oceanview_deactivated).id]

          assert_no_difference 'CoursesTrack.count' do
            post track_courses_url(as: users(role), track_id: @active_track.id),
              params: { track: { course_ids: invalid_course_ids } }
          end
          assert_redirects_with_not_found_error
        end

        test 'when course ids is empty' do
          assert_raises ActionController::ParameterMissing do
            post track_courses_url(as: users(role), track_id: @active_track.id),
              params: { track: {} }
          end
        end

        test 'with valid params and notify employees true' do
          # Ensure suspended/terminated employees are NOT notified
          employee_records(:eric).suspended!

          course_ids = [courses(:canned_for_ohio).id]
          expected_assignments_created_count = (course_ids.size * @active_track.employee_records.size)

          assert_differences([
            ['CoursesTrack.count', 1],
            ['ActionMailer::Base.deliveries.size', @active_track.employee_records.employed.count],
            ['Assignment.count', expected_assignments_created_count]
          ]) do
            perform_enqueued_jobs do
              post track_courses_url(as: users(role), track_id: @active_track.id),
                params: { track: { course_ids: course_ids, notify_employees: 1 } }
            end
          end
          assert_redirects_with_flash_success(@active_track)
        end

        test 'with valid params and notify employees false' do
          course_ids = [courses(:canned_for_ohio).id]
          expected_assignments_created_count = (course_ids.size * @active_track.employee_records.size)

          assert_differences([['CoursesTrack.count', 1], ['Assignment.count', expected_assignments_created_count]]) do
            assert_no_difference 'ActionMailer::Base.deliveries.size' do
              post track_courses_url(as: users(role), track_id: @active_track.id),
                params: { track: { course_ids: course_ids } }
            end
          end
          assert_redirects_with_flash_success(@active_track)
        end
      end
    end

    test "for employee" do
      assert_no_difference 'OfficesUser.count' do
        post track_courses_url(as: users(:employee), track_id: @active_track.id)
      end
      assert_redirects_with_not_authorized_error
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user do
      delete track_course_url(track_id: @active_track.id, id: @active_track_course.id)
    end

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when track does NOT belong to their account' do
          assert_no_difference 'CoursesTrack.count' do
            delete track_course_url(as: users(role), track_id: @another_active_track.id, id: @active_track_course.id)
          end
          assert_redirects_with_not_found_error
        end

        test 'when track is deactivated' do
          assert_no_difference 'CoursesTrack.count' do
            delete track_course_url(as: users(role), track_id: @deactivated_track.id, id: @active_track_course.id)
          end
          assert_redirects_with_not_found_error
        end

        test 'when course id does NOT belong to given track' do
          assert_no_difference 'CoursesTrack.count' do
            delete track_course_url(as: users(role), track_id: @active_track.id, id: courses(:with_expiration).id)
          end
          assert_redirects_with_not_found_error
        end

        test 'when track belongs to their account and course also belongs to other tracks' do
          assert_differences([
            ['CoursesTrack.count', -1],
            ['Assignment.count', 0]
          ]) do
            delete track_course_url(as: users(role), track_id: @active_track.id, id: @active_track_course.id)
          end
          assert_redirects_with_flash_success(@active_track)
        end

        test 'when track belongs to their account and course does NOT belong to other tracks' do
          course = courses(:belonging_to_only_one_track)

          assert_differences([
            ['CoursesTrack.count', -1],
            ['Assignment.count', -@active_track.employee_records.count]
          ]) do
            delete track_course_url(as: users(role), track_id: @active_track.id, id: course.id)
          end
          assert_redirects_with_flash_success(@active_track)
        end
      end
    end
  end
end
