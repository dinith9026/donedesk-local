require 'test_helper'

class OfficeUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @office = offices(:oceanview_tx)
    @account_owner = users(:account_owner)
    @other_office = offices(:brookside)
    @admin_user = users(:account_manager)
  end

  describe '#create' do
    it_requires_authenticated_user { post office_users_url(@office) }

    describe 'for account owner' do
      test 'when office does NOT belong to their account' do
        assert_no_difference 'OfficesUser.count' do
          post office_users_url(@other_office, as: @account_owner),
            params: { office: {} }
        end
        assert_redirects_with_not_found_error
      end

      test 'when user id does NOT belong to their account' do
        invalid_user_ids = [users(:another_employee).id]

        assert_no_difference 'OfficesUser.count', 1 do
          post office_users_url(@office, as: @account_owner),
            params: { office: { user_ids: invalid_user_ids } }
        end
        assert_redirects_with_not_found_error
      end

      test 'with valid params' do
        user_ids = [users(:account_manager).id]

        assert_difference 'OfficesUser.count', 1 do
          post office_users_url(@office, as: @account_owner),
            params: { office: { user_ids: user_ids } }
        end
        assert_redirects_with_flash_success(office_path(@office))
      end
    end

    [:account_manager, :employee].each do |role|
      test "for an #{role}" do
        user = users(role)

        assert_no_difference 'OfficesUser.count' do
          post office_users_url(@office, as: user),
            params: { office: {} }
        end
        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete office_user_url(@office, @admin_user) }

    describe 'for account owner' do
      test 'when office does NOT belong to their account' do
        assert_no_difference 'OfficesUser.count' do
          delete office_user_url(@other_office, @admin_user, as: @account_owner)
        end
        assert_redirects_with_not_found_error
      end

      test 'when user does NOT belong to their account' do
        other_user = users(:another_employee)

        assert_no_difference 'OfficesUser.count', 1 do
          delete office_user_url(@office, other_user, as: @account_owner),
            params: { office: {} }
        end
        assert_redirects_with_not_found_error
      end

      test 'when office and user belong to their account' do
        create(:offices_user, office: @office, user: @admin_user)

        assert_difference 'OfficesUser.count', -1 do
          delete office_user_url(@office, @admin_user, as: @account_owner)
        end
        assert_redirects_with_flash_success(root_path)
      end
    end

    [:account_manager, :employee].each do |role|
      test "for an #{role}" do
        user = users(role)

        assert_no_difference 'OfficesUser.count' do
          delete office_user_url(@office, @admin_user, as: user)
        end
        assert_redirects_with_not_authorized_error
      end
    end
  end
end
