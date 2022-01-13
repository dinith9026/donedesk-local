require 'test_helper'

class UserOfficesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @office = offices(:oceanview_tx)
    @account_owner = users(:account_owner)
    @other_office = offices(:brookside)
    @admin_user = users(:account_manager)
    @other_user = users(:another_employee)
  end

  describe '#create' do
    it_requires_authenticated_user { post user_offices_url(@office) }

    describe 'for account owner' do
      test 'when user does NOT belong to their account' do
        assert_no_difference 'OfficesUser.count' do
          post user_offices_url(@other_user, as: @account_owner)
        end
        assert_redirects_with_not_found_error
      end

      test 'when office id does NOT belong to their account' do
        invalid_office_ids = [offices(:brookside).id]

        assert_no_difference 'OfficesUser.count', 1 do
          post user_offices_url(@admin_user, as: @account_owner),
            params: { user: { office_ids: invalid_office_ids } }
        end
        assert_redirects_with_not_found_error
      end

      test 'with valid params' do
        office_ids = [@office.id]

        assert_difference 'OfficesUser.count', 1 do
          post user_offices_url(@admin_user, as: @account_owner),
            params: { user: { office_ids: office_ids } }
        end
        assert_redirects_with_flash_success(root_path)
      end
    end

    [:account_manager, :employee].each do |role|
      test "for an #{role}" do
        user = users(role)

        assert_no_difference 'OfficesUser.count' do
          post user_offices_url(@admin_user, as: user)
        end
        assert_redirects_with_not_authorized_error
      end
    end
  end
end
