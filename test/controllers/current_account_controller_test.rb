require 'test_helper'

class CurrentAccountControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:oceanview_dental)
    @super_admin = users(:super_admin)
  end

  describe '#update' do
    [:account_owner, :account_manager, :employee].each do |role|
      test "for #{role}" do
        user = users(role)

        put current_account_url(as: user, current_account_name: @account.name)

        assert_redirects_with_not_authorized_error
      end
    end

    describe 'for super_admin' do
      test 'when account does NOT exist' do
        put current_account_url(as: @super_admin, current_account_name: 'non-existent')

        assert_redirected_to '/404'
      end

      test 'when account exists' do
        put current_account_url(as: @super_admin, current_account_name: @account.name)

        assert_redirected_to offices_url
        assert_equal @account.id, session[:current_account_id]
      end
    end
  end
end
