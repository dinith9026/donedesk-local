require 'test_helper'

class ChoicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:oceanview_dental)
    @another_account = accounts(:brookside_dental)

    @account_owner = users(:account_owner)
    @employee_user = users(:employee)

    @course = courses(:oceanview_handbook)
    @another_course = courses(:brookside_handbook)
    @choice = choices(:wrong)
    @another_choice = @another_course.questions.first.choices.first
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete choice_url(@choice) }

    describe 'for account_owner' do
      test 'when record does NOT belong to their account' do
        delete choice_url(@another_choice, as: @account_owner)

        assert_redirects_with_not_authorized_error
      end

      test 'when record belongs to their account' do
        assert_difference 'Choice.count', -1 do
          delete choice_url(@choice, as: @account_owner)
        end
        assert_response :redirect
        assert_redirected_to @course
        refute_nil flash[:success]
      end
    end

    test 'for employee it restricts access' do
      delete choice_url(@choice, as: @employee_user)

      assert_redirects_with_not_authorized_error
    end
  end
end
