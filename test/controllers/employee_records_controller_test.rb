require 'test_helper'

class EmployeeRecordsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @account = accounts(:oceanview_dental)
    @employee_record = employee_records(:ed)
    @another_account = accounts(:brookside_dental)
    @another_employee_record = employee_records(:ellen)
  end

  describe '#index' do
    it_requires_authenticated_user { get employee_records_url }

    test "for account_owner it lists only the records for their account" do
      user = users(:account_owner)

      get employee_records_url(as: user)

      assert_response :success
      assert_includes assigns[:employee_records_presenter], @employee_record
      refute_includes assigns[:employee_records_presenter], @another_employee_record
    end

    test 'for employee it restricts access' do
      user = users(:employee)

      get employee_records_url(as: user)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#new' do
    it_requires_authenticated_user { get new_employee_record_url }

    test 'for account_owner' do
      user = users(:account_owner)

      get new_employee_record_url(as: user)

      assert_response :success
      assert_kind_of EmployeeRecordForm, assigns[:form]
    end

    describe 'for account_manager' do
      test 'when they have no employee record yet' do
        user = users(:account_manager_with_no_employee_record)

        get new_employee_record_url(as: user)

        assert_response :success
        assert_kind_of EmployeeRecordForm, assigns[:form]
      end

      test 'when they have an employee record' do
        user = users(:account_manager)

        get new_employee_record_url(as: user)

        assert_response :success
        assert_kind_of EmployeeRecordForm, assigns[:form]
      end
    end

    describe 'for employee' do
      test 'when they have no employee record yet' do
        user = users(:employee_with_no_employee_record)

        get new_employee_record_url(as: user)

        assert_response :success
        assert_kind_of EmployeeRecordForm, assigns[:form]
      end

      test 'when they have an employee record' do
        user = users(:employee)

        get new_employee_record_url(as: user)

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#create' do
    it_requires_authenticated_user { post employee_records_url }

    describe 'for account_owner' do
      setup do
        # These tracks share courses, which tests/ensures that we're calling `Assignment.find_or_create_by!`
        track = tracks(:for_oceanview)
        track_with_deactivated_course = tracks(:with_3_active_courses_and_1_deactivated_course)
        unique_courses = (track_with_deactivated_course.courses.active.pluck(:id) + track.courses.active.pluck(:id)).uniq
        @track_ids = [track.id, track_with_deactivated_course.id]
        @expected_assignments_count = unique_courses.length
        @expected_assigned_tracks_count = @track_ids.length
      end

      test 'when params are invalid' do
        user = users(:account_owner)
        invalid_params = attributes_for(:employee_record).merge(office_id: nil)

        assert_no_difference [
          'EmployeeRecord.count',
          'AssignedTrack.count',
          'Assignment.count',
          'ActionMailer::Base.deliveries.size'
        ] do
          perform_enqueued_jobs do
            post employee_records_url(as: user), params: { employee_record: invalid_params }
          end
        end
        assert_response :success
        refute_nil flash[:error]
        assert_template :new
        assert_kind_of EmployeeRecordForm, assigns[:form]
      end

      test 'when params are valid and no invite and assigned tracks' do
        user = users(:account_owner)
        office = user.account_offices.first
        document_group = document_groups(:oceanview_default)

        valid_params =
          attributes_for(:employee_record)
          .merge(
            office_id: office.id,
            document_group_id: document_group.id,
            track_ids: @track_ids
          )

        assert_differences [
          ['EmployeeRecord.count', 1],
          ['AssignedTrack.count', @expected_assigned_tracks_count],
          ['Assignment.count', @expected_assignments_count],
          ['ActionMailer::Base.deliveries.size', 0]
        ] do
          perform_enqueued_jobs do
            post employee_records_url(as: user), params: { employee_record: valid_params }
          end
        end
        assert_redirects_with_flash_success employee_records_url
      end

      test 'when params are valid and invite and assigned tracks' do
        user = users(:account_owner)
        office = user.account_offices.first
        document_group = document_groups(:oceanview_default)

        valid_params =
          attributes_for(:employee_record)
          .merge(
            office_id: office.id,
            document_group_id: document_group.id,
            track_ids: @track_ids,
            user: attributes_for(:user, role: 'account_manager', avatar: fixture_file_upload('selfie.jpg', 'image/jpg'))
          )

        assert_differences [
          ['EmployeeRecord.count', 1],
          ['User.count', 1],
          ['ActionMailer::Base.deliveries.size', 1],
          ['AssignedTrack.count', @expected_assigned_tracks_count],
          ['Assignment.count', @expected_assignments_count]
        ] do
          perform_enqueued_jobs do
            post employee_records_url(as: user), params: { employee_record: valid_params }
          end
        end

        last_employee_record = EmployeeRecord.find_by(last_name: valid_params[:last_name])
        last_user = User.find_by(email: valid_params[:user][:email])

        assert_redirects_with_flash_success employee_records_url
        assert_equal last_user.id, last_employee_record.user_id
        assert_equal valid_params[:agd_member_number], last_employee_record.agd_member_number
        assert_nil last_user.two_factor_enabled
        refute_nil last_user.avatar
      end

      test 'when params are valid and user email already exists and user has no employee record and assigned tracks' do
        existing_user = users(:employee_with_no_employee_record)
        user = users(:account_owner)
        office = user.account_offices.first
        document_group = user.account.document_groups.first

        valid_params =
          attributes_for(:employee_record)
          .merge(
            office_id: office.id,
            document_group_id: document_group.id,
            track_ids: @track_ids,
            user: attributes_for(:user, email: existing_user.email)
          )

        assert_no_difference [
          'User.count',
          'EmployeeRecord.count',
          'ActionMailer::Base.deliveries.size',
          'AssignedTrack.count',
          'Assignment.count'
        ] do
          perform_enqueued_jobs do
            post employee_records_url(as: user), params: { employee_record: valid_params }
          end
        end
        assert_response :success
        refute_nil flash[:error]
        assert_template :new
        assert_kind_of EmployeeRecordForm, assigns[:form]
      end
    end

    describe 'for account_manager' do
      test 'when they have no employee record yet' do
        user = users(:account_manager_with_no_employee_record)
        office = user.account_offices.first
        document_group = document_groups(:oceanview_default)
        valid_params = attributes_for(:employee_record).merge(office_id: office.id, document_group_id: document_group.id)

        assert_difference 'EmployeeRecord.count', 1 do
          post employee_records_url(as: user), params: { employee_record: valid_params }
        end
        assert_response :redirect
        refute_nil flash[:success]
        assert_redirected_to employee_records_url
        assert_nil EmployeeRecord.find_by(last_name: valid_params[:last_name]).user_id
      end

      test 'when they have an employee record' do
        user = users(:account_manager)
        office = user.account_offices.first
        document_group = document_groups(:oceanview_default)

        valid_params =
          attributes_for(:employee_record)
          .merge(
            office_id: office.id,
            document_group_id: document_group.id
          )

        assert_difference 'EmployeeRecord.count', 1 do
          post employee_records_url(as: user), params: { employee_record: valid_params }
        end
        assert_response :redirect
        refute_nil flash[:success]
        assert_redirected_to employee_records_url
        assert_nil EmployeeRecord.find_by(last_name: valid_params[:last_name]).user_id
      end
    end

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when params are valid and user email already exists and user already has employee record' do
          existing_user = users(:employee)
          user = users(role)
          office = user.account_offices.first

          valid_params =
            attributes_for(:employee_record)
            .merge(
              office_id: office.id,
              user: attributes_for(:user, email: existing_user.email)
            )

          assert_no_difference [
            'EmployeeRecord.count',
            'User.count',
            'ActionMailer::Base.deliveries.size'
          ] do
            perform_enqueued_jobs do
              post employee_records_url(as: user), params: { employee_record: valid_params }
            end
          end
          assert_response :success
          refute_nil flash[:error]
          assert_template :new
          assert_kind_of EmployeeRecordForm, assigns[:form]
        end
      end
    end

    describe 'for employee' do
      test 'when they have no employee record yet' do
        user = users(:employee_with_no_employee_record)
        office = user.account_offices.first
        document_group = document_groups(:oceanview_default)
        valid_params =
          attributes_for(:employee_record)
          .merge(office_id: office.id)
          .merge(document_group_id: document_group.id)
          .merge(user: attributes_for(:user, email: user.email))

        assert_difference 'EmployeeRecord.count', 1 do
          post employee_records_url(as: user), params: { employee_record: valid_params }
        end
        assert_response :redirect
        refute_nil flash[:success]
        assert_redirected_to dashboard_url
        assert_equal user.id, EmployeeRecord.find_by(last_name: valid_params[:last_name]).user_id
      end

      test 'when they have an employee record' do
        user = users(:employee)
        office = user.account_offices.first
        valid_params = attributes_for(:employee_record).merge(office_id: office.id)

        assert_no_difference 'EmployeeRecord.count' do
          post employee_records_url(as: user), params: { employee_record: valid_params }
        end
        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#show' do
    it_requires_authenticated_user { get employee_record_url(@employee_record) }

    test 'for super_admin' do
      user = users(:super_admin)

      put current_account_url(as: user, current_account_name: @account.name)

      get employee_record_url(as: user, id: @employee_record.id)

      assert_response :success
      refute_nil assigns[:employee_record_presenter]
    end

    describe 'for account owner' do
      test 'when employee has a login' do
        user = users(:account_owner)

        get employee_record_url(as: user, id: @employee_record.id)

        assert_response :success
        refute_nil assigns[:employee_record_presenter]
      end

      test 'when employee has NO login' do
        user = users(:account_owner)

        get employee_record_url(as: user, id: employee_records(:with_no_user).id)

        assert_response :success
        refute_nil assigns[:employee_record_presenter]
      end
    end

    describe 'for employee' do
      test 'when record is not their own it fails' do
        user = users(:employee)
        another_employee = @another_employee_record

        get employee_record_url(as: user, id: another_employee.id)

        assert_redirects_with_not_found_error
      end

      test 'when record is their own it succeeds' do
        user = @employee_record.user
        employee_note =
          @employee_record
          .employee_notes
          .create!(body: "employee note #{SecureRandom.hex}", creator: @account.owner)

        get employee_record_url(as: user, id: user.employee_record.id)

        assert_response :success

        assert_equal user.employee_record.id, assigns[:employee_record].id
        refute_match employee_note.body, response.body
      end
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_employee_record_url(@employee_record) }

    describe 'for account_owner' do
      test 'when record does not belong to their account it fails' do
        user = users(:account_owner)
        another_employee = @another_account.employee_records.first

        get edit_employee_record_url(as: user, id: another_employee.id)

        assert_redirects_with_not_found_error
      end

      test 'when record belongs to their account it succeeds' do
        user = users(:account_owner)
        employee = user.account.employee_records.first

        get edit_employee_record_url(as: user, id: employee.id)

        assert_response :success
      end
    end

    describe 'for employee' do
      test 'when record is not their own it fails' do
        user = users(:employee)
        coworker = employee_records(:eric)

        get edit_employee_record_url(as: user,
                                     id: coworker.id)

        assert_redirects_with_not_authorized_error
      end

      test 'when record is their own it succeeds' do
        user = users(:employee)

        get edit_employee_record_url(as: user, id: user.employee_record.id)

        assert_response :success
        assert_equal user.employee_record.id, assigns[:employee_record].id
      end
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put employee_record_url(@employee_record) }

    describe 'for account_owner' do
      test 'when record does not belong to their account it fails' do
        user = users(:account_owner)
        another_employee = @another_account.employee_records.first

        get edit_employee_record_url(as: user, id: another_employee.id)

        assert_redirects_with_not_found_error
      end

      test 'when record belongs to their account it succeeds' do
        user = users(:account_owner)
        employee_record = user.account_employee_records.first
        new_title = 'Changed'

        put employee_record_url(as: user, id: employee_record.id, params: { employee_record: { title: new_title }})

        assert_response :redirect
        refute_nil flash[:success]
        assert_redirected_to employee_record_url(employee_record)
        assert_equal new_title, EmployeeRecord.find(employee_record.id).title
      end

      test 'when record has no user login' do
        user = users(:account_owner)
        employee_record = employee_records(:with_no_user)
        new_title = 'Changed'

        put employee_record_url(as: user, id: employee_record.id, params: { employee_record: { title: new_title }})

        assert_response :redirect
        refute_nil flash[:success]
        assert_redirected_to employee_record_url(employee_record)
        assert_equal new_title, EmployeeRecord.find(employee_record.id).title
      end

    end

    describe 'for employee' do
      test 'when record is not their own it fails' do
        user = users(:employee)
        coworker = employee_records(:eric)

        new_title = 'Changed'

        put employee_record_url(as: user, id: coworker.id),
              params: { employee_record: { title: new_title } }

        assert_redirects_with_not_authorized_error
        refute_equal new_title, coworker.reload.title
      end

      test 'when record is their own it succeeds' do
        user = users(:employee)
        new_title = 'Changed'

        put employee_record_url(as: user, id: user.employee_record.id, params: { employee_record: { title: new_title }})

        assert_response :redirect
        refute_nil flash[:success]
        assert_equal new_title, EmployeeRecord.find(user.employee_record.id).title
      end
    end
  end

  describe '#create_assignments' do
    it_requires_authenticated_user {
      post assignments_employee_record_url(@employee_record)
    }

    describe 'for account_owner' do
      test 'when record does not belong to their account' do
        user = users(:account_owner)
        another_employee = @another_employee_record

        assert_no_difference 'Assignment.count' do
          post assignments_employee_record_url(as: user, id: another_employee.id)
        end
        assert_redirects_with_not_found_error
      end

      describe 'when record belongs to their account' do
        test 'when no courses given' do
          user = users(:account_owner)
          employee = employee_records(:with_no_assigned_courses)

          assert_no_difference 'Assignment.count' do
            post assignments_employee_record_url(
              as: user, id: employee.id, course_ids: [])
          end
          assert_response :redirect
          refute_nil flash[:error]
        end

        test 'when a given course does not exist' do
          user = users(:account_owner)
          employee = employee_records(:with_no_assigned_courses)
          course_ids = [courses(:oceanview_handbook).id, 'non-existent']

          assert_no_difference 'Assignment.count' do
            post assignments_employee_record_url(
              as: user, id: employee.id, course_ids: course_ids)
          end
          assert_redirects_with_not_found_error
        end

        test 'when given courses are valid' do
          user = users(:account_owner)
          employee = employee_records(:with_no_assigned_courses)
          course_ids = [courses(:oceanview_handbook).id, courses(:canned).id]
          count_before = Assignment.count

          assert_difference 'ActionMailer::Base.deliveries.size', 1 do
            perform_enqueued_jobs do
              post assignments_employee_record_url(
                as: user, id: employee.id, course_ids: course_ids)
            end
          end
          assert_response :redirect
          refute_nil flash[:success]
          assert_equal count_before + course_ids.count, Assignment.count
        end

        test 'when employee_record has no login' do
          user = users(:account_owner)
          employee_record = employee_records(:with_no_user)
          course_ids = [courses(:oceanview_handbook).id, courses(:canned).id]
          count_before = Assignment.count

          assert_no_difference 'ActionMailer::Base.deliveries.size' do
            perform_enqueued_jobs do
              post assignments_employee_record_url(
                as: user, id: employee_record.id, course_ids: course_ids)
            end
          end
          assert_response :redirect
          refute_nil flash[:success]
          assert_equal count_before + course_ids.count, Assignment.count
        end
      end
    end

    test 'for employee it restricts access' do
      user = users(:employee)

      post assignments_employee_record_url(as: user, id: user.employee_record.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#create_assigned_tracks' do
    it_requires_authenticated_user {
      post assigned_tracks_employee_record_url(@employee_record)
    }

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when record does not belong to their account' do
          assert_no_difference 'AssignedTrack.count' do
            post assigned_tracks_employee_record_url(as: users(role), id: @another_employee_record.id)
          end
          assert_redirects_with_not_found_error
        end

        describe 'when record belongs to their account' do
          test 'when no tracks given' do
            assert_no_difference 'AssignedTrack.count' do
              post assigned_tracks_employee_record_url(
                as: users(role), id: @employee_record.id, track_ids: [])
            end
            assert_redirects_with_flash_error(employee_record_url(@employee_record))
          end

          test 'when a given track does not exist' do
            track_ids = [tracks(:for_oceanview).id, 'non-existent']

            assert_no_difference 'AssignedTrack.count' do
              post assigned_tracks_employee_record_url(
                as: users(role), id: @employee_record.id, track_ids: track_ids)
            end
            assert_redirects_with_not_found_error
          end

          test 'when given tracks are valid and employee record has a login' do
            employee_record = employee_records(:with_no_assigned_courses)
            track1 = tracks(:for_oceanview)
            track2 = tracks(:for_oceanview2)
            track_ids = [track1.id, track2.id]
            expected_assignments_count = (track1.courses + track2.courses).uniq.length

            assert_differences([
              ['AssignedTrack.count', track_ids.length],
              ['Assignment.count', expected_assignments_count],
              ['ActionMailer::Base.deliveries.size', 1]
            ]) do
              perform_enqueued_jobs do
                post assigned_tracks_employee_record_url(
                  as: users(role), id: employee_record.id, track_ids: track_ids)
              end
            end
            assert_redirects_with_flash_success(employee_record_url(employee_record))
          end

          test 'when given tracks are valid and employee_record has NO login' do
            employee_record = employee_records(:with_no_user)
            track_ids = [tracks(:for_oceanview).id, tracks(:for_oceanview2).id]

            assert_differences([
              ['ActionMailer::Base.deliveries.size', 0],
              ['AssignedTrack.count', 2]
            ]) do
              perform_enqueued_jobs do
                post assigned_tracks_employee_record_url(
                  as: users(role), id: employee_record.id, track_ids: track_ids)
              end
            end
            assert_redirects_with_flash_success(employee_record_url(employee_record))
          end
        end
      end
    end

    test 'for employee it restricts access' do
      post assigned_tracks_employee_record_url(as: users(:employee), id: @employee_record.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#suspend' do
    it_requires_authenticated_user { put suspend_employee_record_url(@employee_record) }

    describe 'for account_owner' do
      test 'when record does not belong to their account it fails' do
        user = users(:account_owner)
        another_employee = @another_account.employee_records.first

        put suspend_employee_record_url(as: user, id: another_employee.id)

        assert_redirects_with_not_found_error
        refute EmployeeRecord.find(another_employee.id).suspended?
      end

      test 'when record belongs to their account it succeeds' do
        user = users(:account_owner)

        assert_differences [
          ['Assignment.count', -@employee_record.assignments.count],
          ['AssignedTrack.count', -@employee_record.assigned_tracks.count]
        ] do
          put suspend_employee_record_url(as: user, id: @employee_record.id)
        end
        assert_redirects_with_flash_success(root_url)
        assert_equal 'suspended', @employee_record.reload.status
      end
    end

    test 'for employee it fails' do
      user = users(:employee)

      put suspend_employee_record_url(as: user, id: user.employee_record.id)

      assert_redirects_with_not_authorized_error
      refute EmployeeRecord.find(user.employee_record.id).terminated?
    end
  end

  describe '#unsuspend' do
    it_requires_authenticated_user { put unsuspend_employee_record_url(@employee_record) }

    describe 'for account_owner' do
      test 'when record does NOT belong to their account' do
        user = users(:account_owner)
        another_employee_record = @another_account.employee_records.first

        put unsuspend_employee_record_url(as: user, id: another_employee_record.id)

        assert_redirects_with_not_found_error
      end

      test 'when records belongs to their account' do
        user = users(:account_owner)
        employee_record = employee_records(:ed)
        employee_record.suspended!

        put unsuspend_employee_record_url(as: user, id: employee_record.id)

        assert_response :redirect
        assert_redirected_to root_url
        assert_equal 'employed', employee_record.reload.status
      end
    end

    test 'for employee it restricts access' do
      user = users(:employee)

      put unsuspend_employee_record_url(as: user, id: user.employee_record.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#terminate' do
    it_requires_authenticated_user { put suspend_employee_record_url(@employee_record) }

    describe 'for account_owner' do
      test 'when record does not belong to their account it fails' do
        user = users(:account_owner)
        another_employee = @another_employee_record

        put terminate_employee_record_url(as: user, id: another_employee.id)

        assert_redirects_with_not_found_error
        refute another_employee.reload.terminated?
      end

      test 'when record belongs to their account it succeeds' do
        user = users(:account_owner)

        assert_differences [
          ['Assignment.count', -@employee_record.assignments.count],
          ['AssignedTrack.count', -@employee_record.assigned_tracks.count]
        ] do
          put terminate_employee_record_url(as: user, id: @employee_record.id)
        end
        assert_redirects_with_flash_success(root_url)
        assert_equal 'terminated', @employee_record.reload.status
        refute_equal nil, @employee_record.terminated_on
      end
    end

    test 'for employee it fails' do
      user = users(:employee)

      put terminate_employee_record_url(as: user, id: user.employee_record.id)

      assert_redirects_with_not_authorized_error
      refute EmployeeRecord.find(user.employee_record.id).terminated?
    end
  end

  describe '#rehire' do
    it_requires_authenticated_user { put rehire_employee_record_url(@employee_record) }

    describe 'for account_owner' do
      test 'when record does NOT belong to their account' do
        user = users(:account_owner)
        another_employee_record = @another_account.employee_records.first

        put rehire_employee_record_url(as: user, id: another_employee_record.id)

        assert_redirects_with_not_found_error
      end

      test 'when records belongs to their account' do
        user = users(:account_owner)
        employee_record = employee_records(:ed)
        employee_record.terminated!

        put rehire_employee_record_url(as: user, id: employee_record.id)

        assert_response :redirect
        assert_redirected_to root_url
        assert_equal 'employed', employee_record.reload.status
        assert_nil employee_record.terminated_on
      end
    end

    test 'for employee it restricts access' do
      user = users(:employee)

      put rehire_employee_record_url(as: user, id: user.employee_record.id)

      assert_redirects_with_not_authorized_error
    end
  end

end
