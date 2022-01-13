require 'test_helper'

class AssignedTracksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @account = accounts(:oceanview_dental)
    @active_track = tracks(:for_oceanview)
    @another_active_track = tracks(:for_brookside)
    @assigned_track = assigned_tracks(:ed_for_oceanview)
    @another_assigned_track = assigned_tracks(:ellen_for_brookside)
  end

  describe '#create' do
    it_requires_authenticated_user { post track_assigned_tracks_url(@active_track) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when track does not belong to their account' do
          assert_no_difference 'Assignment.count' do
            post track_assigned_tracks_url(as: users(role), track_id: @another_active_track.id)
          end
          assert_redirects_with_not_found_error
        end

        test 'when employee record does not belong to their account' do
          assert_no_difference 'Assignment.count' do
            post track_assigned_tracks_url(as: users(role), track_id: @active_track.id, employee_record_ids: [employee_records(:ellen)])
          end
          assert_redirects_with_not_found_error
        end

        test 'when employee not employed status' do
          employee_record = employee_records(:ed)
          employee_record.suspended!

          assert_no_difference 'Assignment.count' do
            post track_assigned_tracks_url(as: users(role), track_id: @active_track.id, employee_record_ids: [employee_record.id])
          end
          assert_redirects_with_not_found_error
        end

        test 'with valid params and notify employees true' do
          employee_record = employee_records(:with_no_assigned_courses)
          employee_record_ids = [employee_record.id]
          expected_assignments_count = @active_track.courses.size * employee_record_ids.size

          assert_differences [
            ['Assignment.count', expected_assignments_count],
            ['ActionMailer::Base.deliveries.size', employee_record_ids.count]
          ] do
            perform_enqueued_jobs do
              post track_assigned_tracks_url(as: users(role), track_id: @active_track.id),
                params: { employee_record_ids: employee_record_ids, notify_employees: 1}
            end
          end
          assert_redirects_with_flash_success(@active_track)
        end

        test 'with valid params and notify employees false' do
          employee_record = employee_records(:with_no_assigned_courses)
          employee_record_ids = [employee_record.id]
          expected_assignments_count = @active_track.courses.size * employee_record_ids.size

          assert_difference 'Assignment.count', expected_assignments_count do
            assert_no_difference 'ActionMailer::Base.deliveries.size' do
              post track_assigned_tracks_url(as: users(role), track_id: @active_track.id),
                params: { employee_record_ids: employee_record_ids }
            end
          end
          assert_redirects_with_flash_success(@active_track)
        end
      end
    end

    test 'for employee it restricts access' do
      assert_no_difference 'Assignment.count' do
        post track_assigned_tracks_url(as: users(:employee), track_id: @active_track.id)
      end
      assert_redirects_with_not_authorized_error
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete assigned_track_url(@assigned_track) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when record does not belong to their account' do
          assert_no_difference ['Assignment.count', 'AssignedTrack.count'] do
            delete assigned_track_url(as: users(role), id: @another_assigned_track.id)
          end
          assert_redirects_with_not_found_error
        end

        test 'when record belongs to their account' do
          expected_assignments_deleted_count =
            count_of_courses_not_in_other_tracks(@account, @assigned_track.track)

          assert_differences([['Assignment.count', expected_assignments_deleted_count], ['AssignedTrack.count', -1]]) do
            delete assigned_track_url(as: users(role), id: @assigned_track.id)
          end
          assert_redirects_with_flash_success(@assigned_track.track)
        end
      end
    end

    test 'for employee it restricts access' do
      assert_no_difference ['Assignment.count', 'AssignedTrack.count'] do
        delete assigned_track_url(as: users(:employee), id: @assigned_track.id)
      end
      assert_redirects_with_not_authorized_error
    end
  end
end
