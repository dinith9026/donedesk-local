require 'test_helper'

class PlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:oceanview_dental)
    @super_admin = users(:super_admin)
  end

  describe '#new' do
    it_requires_authenticated_user { get new_account_plan_url(account_id: @account.id) }

    test 'for super admin it succeeds' do
      get new_account_plan_url(as: @super_admin, account_id: @account)

      assert_response :success
      refute_nil assigns[:account]
      refute_nil assigns[:form]
    end

    [:account_owner, :employee].each do |role|
      test "for #{role} it restricts access" do
        get new_account_plan_url(as: users(role), account_id: @account)

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#create' do
    it_requires_authenticated_user { post account_plans_url(account_id: @account.id) }

    describe 'for super admin' do
      test 'when params are invalid' do
        post account_plans_url(as: @super_admin, account_id: @account.id),
          params: { plan: invalid_params }

        assert_response :success
        refute_nil flash[:error]
        refute_nil assigns[:form]
      end

      test 'when params are valid' do
        InitializeBilling.call(@account, stripe_card_token)
        existing_plan_id = @account.plan.id
        plan_params = valid_params

        post account_plans_url(as: @super_admin, account_id: @account.id),
              params: { plan: plan_params }

        assert_response :redirect
        refute_nil flash[:success]
        refute_equal existing_plan_id, @account.reload.plan.id
        assert_equal plan_params[:monthly_price].to_i, @account.plan_monthly_price
        assert_equal plan_params[:max_employees].to_i, @account.plan_max_employees
      end
    end

    [:account_owner, :employee].each do |role|
      test "for #{role} it restricts access" do
        post account_plans_url(as: users(role), account_id: @account.id),
              params: { plan: valid_params}

        assert_redirects_with_not_authorized_error
      end
    end
  end

  private

  def valid_params
    attributes_for(:plan)
  end

  def invalid_params
    attributes_for(:plan, monthly_price: '')
  end
end
