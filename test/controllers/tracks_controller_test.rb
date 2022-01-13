require 'test_helper'

class TracksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:oceanview_dental)
    @active_track = tracks(:for_oceanview)
    @deactivated_track = tracks(:for_oceanview_deactivated)
    @another_active_track = tracks(:for_brookside)
    @another_deactivated_track = tracks(:for_brookside_deactivated)
  end

  describe '#index' do
    it_requires_authenticated_user { get tracks_url }

    [:account_owner, :account_manager].each do |role|
      test "as #{role}" do
        get tracks_url(as: users(role))

        assert_response :success
        assert_includes assigns.keys, 'tracks_presenter'
        assert_equal @account.tracks.size, assigns[:tracks_presenter].size
        refute_includes assigns[:tracks_presenter].map(&:id), tracks(:for_brookside).id,
          "Should NOT include `#{tracks(:for_brookside).name}`"
      end
    end

    test 'for employee' do
      get tracks_url(as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#new' do
    it_requires_authenticated_user { get new_track_url }

    [:account_owner, :account_manager].each do |role|
      test "as #{role}" do
        get new_track_url(as: users(role))

        assert_response :success
        assert_includes assigns.keys, 'form'
        assert_includes assigns[:form].courses, courses(:oceanview_handbook)
        assert_includes assigns[:form].courses, courses(:canned)
        refute_includes assigns[:form].courses, courses(:brookside_handbook)
      end
    end

    test 'for employee' do
      get new_track_url(as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#create' do
    it_requires_authenticated_user { post tracks_url }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when params are invalid' do
          assert_no_difference ['Track.count', 'CoursesTrack.count'] do
            post tracks_url(as: users(role)), params: { track: { name: '' } }
          end
          assert_response :success
          assert_template :new
          assert_includes assigns.keys, 'form'
          assert_includes assigns[:form].courses, courses(:oceanview_handbook)
          assert_includes assigns[:form].courses, courses(:canned)
          refute_includes assigns[:form].courses, courses(:brookside_handbook)
        end

        test "when params are valid" do
          user = users(role)
          name = "Track #{SecureRandom.hex}"
          course1 = courses(:oceanview_handbook)
          course2 = courses(:canned)
          valid_params = {
            track: {
              name: name,
              course_ids: [course1.id, course2.id]
            }
          }

          assert_differences([['Track.count', 1], ['CoursesTrack.count', 2]]) do
            post tracks_url(as: user), params: valid_params
          end

          new_track = Track.find_by(name: name)

          assert_redirects_with_flash_success(track_path(new_track))
          assert_equal name, new_track.name
          assert_equal user.account_id, new_track.account_id
          assert_includes new_track.courses, course1
          assert_includes new_track.courses, course2
        end
      end
    end

    test 'for employee' do
      post tracks_url(as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#show' do
    it_requires_authenticated_user { get track_url(@active_track) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when record does not belong to their account' do
          get track_url(as: users(role), id: @another_active_track.id)

          assert_redirects_with_not_found_error
        end

        test 'when record belongs to their account' do
          get track_url(as: users(role), id: @active_track.id)

          assert_response :success
          assert_includes assigns.keys, 'track_presenter'
        end
      end
    end

    test 'for employee it restricts access' do
      get track_url(as: users(:employee), id: @active_track.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_track_url(@active_track) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when record does not belong to their account' do
          get edit_track_url(as: users(role), id: @another_active_track.id)

          assert_redirects_with_not_found_error
        end

        test 'when record belongs to their account' do
          get edit_track_url(as: users(role), id: @active_track.id)

          assert_response :success
          refute_nil assigns[:form]
        end
      end
    end

    test 'for employee it restricts access' do
      get edit_track_url(as: users(:employee), id: @active_track.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put track_url(@active_track) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when record does not belong to their account' do
          put track_url(as: users(role), id: @another_active_track.id)

          assert_redirects_with_not_found_error
        end

        test 'when record belongs to their account and params are INVALID' do
          invalid_params = { name: '' }
          updated_at_before = @active_track.updated_at

          put track_url(as: users(role), id: @active_track.id), params: { track: invalid_params }

          assert_response :success
          assert_template :edit
          refute_nil assigns[:form]
          assert_equal updated_at_before, @active_track.reload.updated_at
        end

        test 'when record belongs to their account and params are VALID' do
          new_name = "New Name #{SecureRandom.hex}"
          valid_params = { name: new_name, course_ids: [courses(:oceanview_handbook).id] }

          put track_url(as: users(role), id: @active_track.id), params: { track: valid_params }

          assert_response :redirect
          assert_redirected_to @active_track
          refute_nil flash[:success]
          assert_equal new_name, @active_track.reload.name
        end
      end
    end

    test 'for employee it restricts access' do
      put track_url(as: users(:employee), id: @active_track.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete track_url(@active_track) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when record does not belong to their account' do
          delete track_url(as: users(role), id: @another_active_track.id)

          assert_redirects_with_not_found_error
        end

        test 'when record belongs to their account' do
          expected_assignments_deleted_count =
            count_of_courses_not_in_other_tracks(@account, @active_track) * @active_track.employee_records.size

          assert_differences [
            ['Assignment.count', expected_assignments_deleted_count],
            ['AssignedTrack.count', -@active_track.employee_records.count],
            ['CoursesTrack.count', -@active_track.courses.count]
          ] do
            delete track_url(as: users(role), id: @active_track.id)
          end
          assert_redirects_with_flash_success(tracks_url)
        end
      end
    end

    test 'for employee it restricts access' do
      delete track_url(as: users(:employee), id: @active_track.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#deactivate' do
    it_requires_authenticated_user { put deactivate_track_url(@active_track) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when record does not belong to their account' do
          put deactivate_track_url(as: users(role), id: @another_active_track.id)

          assert_redirects_with_not_found_error
        end

        test 'when record belongs to their account and is already deactivated' do
          put deactivate_track_url(as: users(role), id: tracks(:for_oceanview_deactivated).id)

          assert_redirects_with_not_found_error
        end

        test 'when record belongs to their account' do
          expected_assignments_deleted_count =
            count_of_courses_not_in_other_tracks(@account, @active_track) * @active_track.employee_records.size

          assert_differences [
            ['Assignment.count', expected_assignments_deleted_count],
            ['AssignedTrack.count', -@active_track.employee_records.count]
          ] do
            put deactivate_track_url(as: users(role), id: @active_track.id)
          end
          assert_response :redirect
          assert_redirected_to track_url(@active_track)
          refute_nil flash[:success]
          assert @active_track.reload.deactivated?
        end
      end
    end

    test 'for employee it restricts access' do
      put deactivate_track_url(as: users(:employee), id: @active_track.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#reactivate' do
    it_requires_authenticated_user { put reactivate_track_url(@deactivated_track) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when record does not belong to their account' do
          put reactivate_track_url(as: users(role), id: @another_deactivated_track.id)

          assert_redirects_with_not_found_error
        end

        test 'when record belongs to their account and is already active' do
          put reactivate_track_url(as: users(role), id: @active_track.id)

          assert_redirects_with_not_found_error
        end

        test 'when record belongs to their account' do
          assert_no_difference 'Assignment.count' do
            put reactivate_track_url(as: users(role), id: @deactivated_track.id)
          end
          assert_response :redirect
          assert_redirected_to track_url(@deactivated_track)
          refute_nil flash[:success]
          assert @deactivated_track.reload.active?
        end
      end
    end

    test 'for employee it restricts access' do
      put reactivate_track_url(as: users(:employee), id: @deactivated_track.id)

      assert_redirects_with_not_authorized_error
    end
  end
end
