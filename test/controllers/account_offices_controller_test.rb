require 'test_helper'

class AccountOfficesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:oceanview_dental)
    @account_owner = @account.owner
    @office = offices(:oceanview_tx)
    @another_office = offices(:brookside)
    @super_admin = users(:super_admin)
  end

  describe '#new' do
    it_requires_authenticated_user { get new_account_office_url(@account) }

    test 'for super_admin' do
      get new_account_office_url(@account, as: @super_admin)

      assert_response :success
      assert_template :new
      refute_nil assigns[:form]
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "for #{role}" do
        get new_account_office_url(@account, as: users(role))

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#create' do
    it_requires_authenticated_user { post account_offices_url(@account) }

    test 'for super_admin when params are VALID' do
      document_group = create_office_document_group_for(@account)
      office_params = attributes_for(:office).merge(document_group_id: document_group.id)

      assert_difference 'Office.count', 1 do
        post account_offices_url(@account, as: @super_admin), params: { office: office_params }
      end
      assert_response :redirect
      assert_redirected_to @account
      refute_nil flash[:success]
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "for #{role}" do
        post account_offices_url(@account, as: users(role))

        assert_redirects_with_not_authorized_error
      end
    end
  end
end
