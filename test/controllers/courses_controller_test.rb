require 'test_helper'

class CoursesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @account = accounts(:oceanview_dental)
    @authorized_user = @account.users.where(role: :account_owner).first
    @another_account = accounts(:brookside_dental)
    @course = courses(:oceanview_handbook)
    @another_course = courses(:brookside_handbook)
  end

  describe '#index' do
    it_requires_authenticated_user { get courses_url }

    test "for account_owner it lists only the records for their account" do
      get courses_url(as: @authorized_user)

      assert_response :success
      refute_nil assigns[:courses_presenter]
      refute_includes assigns[:courses_presenter], @another_account.custom_courses.first
    end

    test 'for employee it restricts access' do
      get courses_url(as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#new' do
    it_requires_authenticated_user { get new_course_url }

    test 'for account_owner it succeeds' do
      get new_course_url(as: @authorized_user)

      assert_response :success
      refute_nil assigns[:form]
    end

    test 'for employee it restricts access' do
      get new_course_url(as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#create' do
    it_requires_authenticated_user { post courses_url }

    describe 'for super_admin' do
      test 'when creating a canned course and params are valid' do
        params = valid_params.merge(is_canned: true)

        assert_difference 'Course.count', 1 do
          post courses_url(as: users(:super_admin)),
               params: { course: params }
        end
        assert_response :redirect
        refute_nil flash[:success]
        assert_nil last_course.account_id
        assert_equal params['supplements'], last_course.supplements
      end

      test 'when creating a canned course and title already taken' do
        existing_course = courses(:canned)
        params = valid_params.merge({
          "title" => existing_course.title,
          "is_canned" => true,
          "supplements" => []
        })

        assert_no_difference 'Course.count' do
          post courses_url(as: users(:super_admin)), params: { course: params }
        end
        assert_response :success
        refute_nil assigns[:form]
      end
    end

    describe 'for account_owner' do
      test 'it succeeds when params are valid' do
        params = valid_params

        assert_difference 'Course.count', 1 do
          post courses_url(as: @authorized_user),
               params: { course: params }
        end

        new_course = last_course

        assert_response :redirect
        refute_nil flash[:success]
        assert_equal params['days_due_within'], new_course.days_due_within
      end

      test 'it fails when params are invalid' do
        assert_no_difference 'Course.count' do
          post courses_url(as: @authorized_user, params: { course: invalid_params })
        end
        assert_response :success
        refute_nil assigns[:form]
      end
    end

    test 'for employee it restricts access' do
      post courses_url(as: users(:employee), params: { course: valid_params })

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#show' do
    it_requires_authenticated_user { get course_url(@course) }

    describe 'for account_owner' do
      test 'when record belongs to their account it succeeds' do
        get course_url(as: @authorized_user, id: @course.id)

        assert_response :success
        refute_nil assigns[:course_presenter]
      end

      test 'when record does not belong to their account it fails' do
        get course_url(as: @authorized_user, id: @another_course.id)

        assert_redirects_with_not_found_error
      end
    end

    test 'for employee it restricts access' do
      get course_url(as: users(:employee), id: @course.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_course_url(@course) }

    describe 'for account_owner' do
      test 'when record belongs to their account it succeeds' do
        get edit_course_url(as: @authorized_user, id: @course.id)

        assert_response :success
        refute_nil assigns[:form]
      end

      test 'when record does not belong to their account it fails' do
        get edit_course_url(as: @authorized_user, id: @another_course.id)

        assert_redirects_with_not_found_error
      end
    end

    test 'for employee it restricts access' do
      get edit_course_url(as: users(:employee), id: @course.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put course_url(@course) }

    describe 'for account_owner' do
      test 'when record belongs to their account and params are VALID it succeeds' do
        new_title = 'New title'
        new_days_due_within = @course.days_due_within + 1
        params = valid_params.merge(
          title: new_title,
          days_due_within: new_days_due_within
        )

        put course_url(as: @authorized_user, id: @course.id),
          params: { course: params }

        @course.reload

        assert_response :redirect
        refute_nil flash[:success]
        assert_equal new_title, @course.title
        assert_equal new_days_due_within, @course.days_due_within
      end

      test 'when record belongs to their account and params are INVALID it fails' do
        new_code = 'NEWCODE'

        put course_url(as: @authorized_user, id: @course.id),
          params: { course: invalid_params.merge(code: new_code) }

        assert_response :success
        assert_template :edit
        refute_nil assigns[:form]
        refute_equal new_code, Course.find(@course.id).code
      end

      test 'when record does not belong to their account it fails' do
        put course_url(as: @authorized_user, id: @another_course.id)

        assert_redirects_with_not_found_error
      end
    end

    test 'for employee it restricts access' do
      put course_url(as: users(:employee), id: @course.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#create_assignments' do
    it_requires_authenticated_user { post assignments_course_url(@course) }

    describe 'for account_owner' do
      test 'when record does not belong to their account' do
        post assignments_course_url(as: @authorized_user, id: @another_course.id)

        assert_redirects_with_not_found_error
      end

      test 'when record belongs to their account' do
        employee_record = employee_records(:with_no_assigned_courses)
        employee_record_ids = [ employee_record.id ]
        account_id = @authorized_user.account_id

        assert_difference('ActionMailer::Base.deliveries.size', employee_record_ids.count) do
          perform_enqueued_jobs do
            post assignments_course_url(as: @authorized_user, id: @course.id),
                params: { employee_record_ids: employee_record_ids }
          end
        end
        assert_response :redirect
        refute_nil flash[:success]
        assert_includes AssignedEmployeesForCourse.new(@course.id, account_id).query, employee_record
      end

      test 'when employee has no login' do
        employee_record = employee_records(:with_no_user)
        employee_record_ids = [ employee_record.id ]
        account_id = @authorized_user.account_id

        assert_no_difference 'ActionMailer::Base.deliveries.size' do
          perform_enqueued_jobs do
            post assignments_course_url(as: @authorized_user, id: @course.id),
                params: { employee_record_ids: employee_record_ids }
          end
        end
        assert_response :redirect
        refute_nil flash[:success]
        assert_includes AssignedEmployeesForCourse.new(@course.id, account_id).query, employee_record
      end
    end

    test 'for employee it restricts access' do
      post assignments_course_url(as: users(:employee), id: @course.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#deactivate' do
    it_requires_authenticated_user { put deactivate_course_url(@course) }

    describe 'for account_owner' do
      test 'when record does not belong to their account' do
        put deactivate_course_url(as: @authorized_user, id: @another_course.id)

        assert_redirects_with_not_found_error
      end

      test 'when record belongs to their account' do
        assert_difference 'CoursesTrack.count', -@course.courses_tracks.count do
          put deactivate_course_url(as: @authorized_user, id: @course.id)
        end
        assert_redirects_with_flash_success(courses_url)
        assert @course.reload.deactivated?
      end
    end

    test 'for employee it restricts access' do
      put deactivate_course_url(as: users(:employee), id: @course.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#reactivate' do
    it_requires_authenticated_user { put reactivate_course_url(@course) }

    describe 'for account_owner' do
      test 'when record does not belong to their account' do
        put reactivate_course_url(as: @authorized_user, id: @another_course.id)

        assert_redirects_with_not_found_error
      end

      test 'when record belongs to their account' do
        @course.deactivate!

        put reactivate_course_url(as: @authorized_user, id: @course.id)

        assert_response :redirect
        refute_nil flash[:success]
        refute @course.reload.deactivated?
      end
    end

    test 'for employee it restricts access' do
      put reactivate_course_url(as: users(:employee), id: @course.id)

      assert_redirects_with_not_authorized_error
    end
  end

  private

  def valid_params
    build(:course).attributes
  end

  def invalid_params
    { title: '' }
  end

  def last_course
    @last_course ||= Course.order(:created_at).last
  end
end
