require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @account = accounts(:oceanview_dental)
    @account_owner = @account.owner
    @another_user = users(:another_account_owner)
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_user_url(@account_owner) }

    describe 'for account owner' do
      test 'when user does NOT belong to their account' do
        get edit_user_url(@another_user, as: @account_owner)

        assert_redirects_with_not_found_error
      end

      test 'when user belongs to their account' do
        user = users(:employee)

        get edit_user_url(user, as: @account_owner)

        assert_response :success
        assert_includes assigns.keys, 'form'
      end
    end

    describe 'for employee' do
      test 'when record is not their own' do
        user = users(:employee)

        put user_url(users(:coworker), as: user)

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put user_url(@account_owner) }

    describe 'for account owner' do
      test 'when user does NOT belong to their account' do
        put user_url(@another_user, as: @account_owner)

        assert_redirects_with_not_found_error
      end

      test 'when user belongs to their account and params are invalid' do
        new_email = 'new_email@example.com'
        user = users(:employee)
        invalid_params = user.attributes.merge(email: new_email).merge(first_name: '')

        put user_url(user, as: @account_owner),
          params: { user: invalid_params }

        assert_response :success
        assert_includes assigns.keys, 'form'
        refute_nil flash[:error]
        refute_equal new_email, user.reload.email
      end

      test 'when user belongs to their account and params are valid' do
        user = users(:employee)
        params = {
          avatar: fixture_file_upload('selfie.jpg', 'image/jpg'),
          email: 'new_email@example.com',
          first_name: 'New First',
          last_name: 'New Last',
          role: (User.roles.keys - [user.role]).sample,
          two_factor_enabled: !user.two_factor_enabled
        }

        put user_url(user, as: @account_owner), params: { user: params }

        user.reload

        assert_response :redirect
        refute_nil flash[:success]
        assert_equal params[:avatar].original_filename, user.avatar_file_name
        assert_equal params[:email], user.email
        assert_equal params[:first_name], user.first_name
        assert_equal params[:last_name], user.last_name
        refute_equal params[:role], user.role
        refute_equal params[:two_factor_enabled], user.two_factor_enabled
      end
    end

    describe 'for employee' do
      test 'when record is not their own' do
        user = users(:employee)

        put user_url(users(:coworker), as: user)

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#make_account_manager' do
    it_requires_authenticated_user { put make_account_manager_user_url(@account_owner) }

    describe 'for account owner' do
      test 'when user does NOT belong to their account' do
        put make_account_manager_user_url(@another_user, as: @account_owner)

        assert_redirects_with_not_found_error
      end

      test 'when user belongs to their account' do
        employee_user = users(:employee)

        put make_account_manager_user_url(employee_user, as: @account_owner)

        assert_response :success
        assert_equal 'account_manager', employee_user.reload.role
      end
    end

    test 'for employee it restricts access' do
      employee_user = users(:employee)

      put make_account_manager_user_url(employee_user, as: employee_user)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#make_employee' do
    it_requires_authenticated_user { put make_employee_user_url(@account_owner) }

    describe 'for account owner' do
      test 'when user does NOT belong to their account' do
        put make_employee_user_url(@another_user, as: @account_owner)

        assert_redirects_with_not_found_error
      end

      test 'when user belongs to their account' do
        account_manager = users(:account_manager)

        put make_employee_user_url(account_manager, as: @account_owner)

        assert_response :success
        assert_equal 'employee', account_manager.reload.role
      end
    end

    test 'for employee it restricts access' do
      employee_user = users(:employee)

      put make_employee_user_url(employee_user, as: employee_user)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#reinvite' do
    it_requires_authenticated_user { post reinvite_user_url(users(:invited_account_owner)) }

    test 'for account owner' do
      user = users(:employee)
      user.update!(confirmation_token: 'test_token')

      assert_difference 'ActionMailer::Base.deliveries.count', 1 do
        perform_enqueued_jobs do
          post reinvite_user_url(as: @account_owner, id: user.id)
        end
      end
      assert_response :redirect
      assert_redirected_to employee_records_url
      refute_nil flash[:success]
    end

    test "for employees it restricts access" do
      post reinvite_user_url(as: users(:employee), id: users(:coworker))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete user_url(@account_owner) }

    test 'for account owner' do
      user = create(:user, :employee, account: @account, employee_record: nil)

      assert_difference 'User.count', -1 do
        delete user_url(as: @account_owner, id: user.id)
      end
      assert_response :redirect
      assert_redirected_to employee_records_url
      refute_nil flash[:success]
    end

    test "for employees it restricts access" do
      delete user_url(as: users(:employee), id: users(:coworker))

      assert_redirects_with_not_authorized_error
    end
  end
end
