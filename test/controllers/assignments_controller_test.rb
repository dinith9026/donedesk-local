require 'test_helper'

class AssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = users(:employee)
    @assignment = assignments(:oceanview_for_course_not_belonging_to_any_tracks)
    @other_assignment = assignments(:brookside_canned)
  end

  describe '#index' do
    it_requires_authenticated_user { get assignments_url }

    test 'when employee has assignments' do
      get assignments_url(as: @employee)

      assert_response :success
      refute_nil assigns[:employee_record_presenter]
    end
  end

  describe '#show' do
    it_requires_authenticated_user { get assignment_url(@assignment) }

    test 'when assignment does NOT belong to employee' do
      get assignment_url(as: @employee, id: @other_assignment.id)

      assert_redirects_with_not_found_error
    end

    test 'when assignment belongs to employee' do
      get assignment_url(as: @employee, id: @assignment.id)

      assert_response :success
      refute_nil assigns[:assignment_presenter]
    end
  end

  describe '#mark_completed' do
    it_requires_authenticated_user { put mark_completed_assignment_url(@assignment) }

    test 'as a super admin' do
      super_admin = users(:super_admin)

      assert_difference 'Certificate.count', 1 do
        put mark_completed_assignment_url(@assignment, as: super_admin)
      end
      assert_response :redirect
      assert_redirected_to root_url
      refute_nil flash[:success]
    end

    [:account_owner, :account_manager].each  do |role|
      describe "as a #{role}" do
        test 'when assignment does NOT belong to current account' do
          user = users(role)

          put mark_completed_assignment_url(@other_assignment, as: user)

          assert_redirects_with_not_authorized_error
        end

        describe 'when assignment belongs to current account' do
          test 'and passed on date is INVALID' do
            user = users(role)

            assert_no_difference 'Certificate.count'  do
              put mark_completed_assignment_url(@assignment, as: user), params: { passed_on: '13/01/2020' }
            end

            assert_response :redirect
            assert_redirected_to root_url
            refute_nil flash[:error]
          end

          test 'and passed on date is VALID' do
            user = users(role)

            assert_difference 'Certificate.count', 1 do
              put mark_completed_assignment_url(@assignment, as: user), params: { passed_on: '07/01/2020' }
            end

            last_certificate = Certificate.order(:created_at).last

            assert_response :redirect
            assert_redirected_to root_url
            refute_nil flash[:success]
            assert_equal '2020-07-01', last_certificate.passed_on.to_s(:db)
          end
        end
      end
    end

    [:employee].each  do |role|
      test "as an #{role}" do
        user = users(role)

        put mark_completed_assignment_url(@assignment, as: user)

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#download' do
    it_requires_authenticated_user { get download_assignment_url(@assignment) }

    test 'when assignment does NOT belong to employee' do
      get download_assignment_url(as: @employee, id: @other_assignment.id)

      assert_redirects_with_not_found_error
    end

    test 'when assignment belongs to employee' do
      url_prefix = 'https://s3.us-west-2.amazonaws.com/com.donedesk.app.test/courses/materials/test_fixture/test.pdf'

      get download_assignment_url(as: @employee, id: @assignment.id)

      assert_includes @assignment.course_material_url, url_prefix
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete assignment_url(@assignment) }

    describe 'for account owner' do
      test 'when assignment does NOT belong to current account' do
        account_owner = users(:account_owner)
        delete assignment_url(as: account_owner, id: @other_assignment.id)

        assert_redirects_with_not_found_error
      end

      test 'when assignment belongs to current account and course is part of a track' do
        account_owner = users(:account_owner)
        assignment = assignments(:oceanview_handbook_for_employee)

        assert_no_difference 'Assignment.count', -1 do
          delete assignment_url(as: account_owner, id: assignment.id)
        end
        assert_redirects_with_not_authorized_error
      end

      test 'when assignment belongs to current account and course is not part of a track' do
        account_owner = users(:account_owner)

        assert_difference 'Assignment.count', -1 do
          delete assignment_url(as: account_owner, id: @assignment.id)
        end
        assert_response :redirect
        assert_redirected_to root_url
      end
    end

    test 'for employee' do
      delete assignment_url(as: @employee, id: @assignment.id)

      assert_redirects_with_not_authorized_error
    end
  end
end
