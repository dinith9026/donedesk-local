require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @super_admin = users(:super_admin)
    @account = accounts(:oceanview_dental)

    DocumentGroupPreset.find_or_create_by(name: 'Default for Offices', applies_to: 'offices', is_default: true) do |preset|
      preset.document_types = [
        { id: document_types(:office_maintenance_checklist).id, required: true, applies_to: 'offices' }
      ]
    end

    DocumentGroupPreset.find_or_create_by(name: 'Default for Employees', applies_to: 'employees', is_default: true) do |preset|
      preset.document_types = [
        { id: document_types(:w4).id, required: true, applies_to: 'employees' }
      ]
    end
  end

  describe '#index' do
    it_requires_authenticated_user { get accounts_url }

    test "for super admin" do
      get accounts_url(as: @super_admin)

      assert_response :success
      refute_nil assigns[:accounts_presenter]
      assert_template 'index'
    end

    [:account_owner, :employee].each do |role|
      test "for #{role} it restricts access" do
        get accounts_url(as: users(role))

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#new' do
    it_requires_authenticated_user { get new_account_url }

    test 'for super admin it succeeds' do
      get new_account_url(as: @super_admin)

      assert_response :success
      refute_nil assigns[:form]
    end

    [:account_owner, :employee].each do |role|
      test "for #{role} it restricts access" do
        get new_account_url(as: users(role))

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#create' do
    it_requires_authenticated_user { post accounts_url }

    describe 'for super admin' do
      test 'when params are invalid' do
        assert_no_difference 'Account.count' do
          post accounts_url(as: @super_admin, params: { account: invalid_params })
        end
        assert_response :success
        refute_nil flash[:error]
        refute_nil assigns[:form]
      end

      test 'when params are valid' do
        valid_params = valid_params_for_create

        assert_differences([
          ['Account.count', 1],
          ['Office.count', 1],
          ['User.count', 1],
          ['DocumentGroup.count', 2],
          ['DocumentTypesGrouping.count', 2]
        ]) do
          perform_enqueued_jobs do
            post accounts_url(as: @super_admin),
                  params: { account: valid_params }
          end
        end

        new_account = Account.find_by(name: valid_params[:name])
        new_document_group_for_offices = DocumentGroup.find_by!(
          account_id: new_account.id,
          name: 'Default for Offices'
        )

        assert_response :redirect
        refute_nil flash[:success]
        assert_equal true, new_account.two_factor_enabled
        assert_equal 'offices', new_document_group_for_offices.applies_to
        assert_match(/Invite: .+ DoneDesk/i, last_email.subject)
      end
    end

    [:account_owner, :employee].each do |role|
      test "for #{role} it restricts access" do
        post accounts_url(as: users(role)),
              params: { account: valid_params_for_create }

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#show' do
    it_requires_authenticated_user { get account_url(@account) }

    test 'for super admin' do
      get account_url(as: @super_admin, id: @account.id)

      assert_response :success
      refute_nil assigns[:account_presenter]
    end

    [:account_owner, :employee].each do |role|
      test "for #{role} it restricts access" do
        get account_url(as: users(role), id: @account.id),
              params: { account: valid_params_for_create }

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_account_url(@account) }

    test 'for super admin' do
      get edit_account_url(as: @super_admin, id: @account.id)

      assert_response :success
      refute_nil assigns[:form]
    end

    [:account_owner, :employee].each do |role|
      test "for #{role} it restricts access" do
        get edit_account_url(as: users(role), id: @account.id)

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put account_url(@account) }

    describe 'for super admin' do
      test 'when params are INVALID' do
        existing_name = accounts(:brookside_dental).name

        put account_url(as: @super_admin, id: @account.id),
          params: { account: invalid_params.merge(name: existing_name) }

        assert_response :success
        assert_template 'edit'
        refute_nil flash[:error]
        refute_nil assigns[:form]
        refute_equal existing_name, @account.reload.name
      end

      test 'when params are VALID' do
        new_name = 'New Name'

        put account_url(as: @super_admin, id: @account.id),
          params: { account: valid_params_for_update.merge(name: new_name) }

        assert_response :redirect
        refute_nil flash[:success]
        assert_equal new_name, Account.find(@account.id).name
      end
    end

    [:account_owner, :employee].each do |role|
      test "for #{role} it restricts access" do
        put account_url(as: users(role), id: @account.id),
            params: { account: valid_params_for_update }

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#deactivate' do
    it_requires_authenticated_user { put deactivate_account_url(@account) }

    test 'for super admin' do
      put deactivate_account_url(as: @super_admin, id: @account.id)

      assert_response :redirect
      refute_nil flash[:success]
      refute Account.find(@account.id).active?
    end

    [:account_owner, :employee].each do |role|
      test "for #{role} it restricts access" do
        put deactivate_account_url(as: users(role), id: @account.id)

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#reactivate' do
    it_requires_authenticated_user { put reactivate_account_url(@account) }

    test 'for super admin' do
      @account.deactivate!

      put reactivate_account_url(as: @super_admin, id: @account.id)

      assert_response :redirect
      refute_nil flash[:success]
      assert @account.reload.active?
    end

    [:account_owner, :employee].each do |role|
      test "for #{role} it restricts access" do
        put reactivate_account_url(as: users(role), id: @account.id)

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#reinvite' do
    it_requires_authenticated_user { post reinvite_account_url(@account) }

    test 'for super admin' do
      account = accounts(:invited)

      assert_difference 'ActionMailer::Base.deliveries.count', 1 do
        perform_enqueued_jobs do
          post reinvite_account_url(as: @super_admin, id: account.id)
        end
      end
      assert_response :redirect
      assert_redirected_to accounts_url
      refute_nil flash[:success]
    end

    [:account_owner, :employee].each do |role|
      test "for #{role} it restricts access" do
        post reinvite_account_url(as: users(role), id: @account.id)

        assert_redirects_with_not_authorized_error
      end
    end
  end

  private

  def valid_params_for_create
    attributes_for(:account, two_factor_enabled: true)
      .merge(user: valid_user_params)
      .merge(office: valid_office_params)
      .merge(plan: valid_plan_params)
  end

  def valid_params_for_update
    attributes_for(:account)
  end

  def valid_user_params
    attributes_for(:user)
  end

  def valid_office_params
    attributes_for(:office)
  end

  def valid_plan_params
    attributes_for(:plan)
  end

  def invalid_params
    params = valid_params_for_create.clone
    params[:name] = ''
    params
  end
end
