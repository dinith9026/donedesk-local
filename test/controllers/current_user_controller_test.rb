require 'test_helper'

class CurrentUserControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account_owner = users(:account_owner)
  end

  describe '#show' do
    it_requires_authenticated_user { get profile_url(@account_owner) }

    test 'for account owner' do
      get profile_url(as: @account_owner)

      assert_response :success
      assert_includes assigns.keys, 'user_presenter'
    end

    test 'for employee' do
      get profile_url(as: users(:employee))

      assert_response :success
      assert_includes assigns.keys, 'user_presenter'
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_profile_url(@account_owner) }

    test 'for account owner' do
      get edit_profile_url(as: @account_owner)

      assert_response :success
      refute_nil assigns[:form]
    end

    test 'for employee' do
      get edit_profile_url(as: users(:employee))

      assert_response :success
      refute_nil assigns[:form]
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put profile_url(@account_owner) }

    describe 'for account owner' do
      test 'when params are INVALID' do
        new_email = 'invalid email'

        put profile_url(as: @account_owner),
          params: { user: invalid_params.merge(email: new_email) }

        assert_response :success
        assert_template :edit
        refute_nil assigns[:form]
        refute_equal new_email, @account_owner.reload.email
      end

      test 'when params are VALID' do
        new_email = 'new@example.com'

        put profile_url(as: @account_owner),
          params: { user: valid_params.merge(email: new_email) }

        assert_response :redirect
        refute_nil flash[:success]
        assert_equal new_email, @account_owner.reload.email
      end
    end

    test 'for employee when params are VALID' do
      employee_user = users(:employee)
      new_email = 'new@example.com'

      put profile_url(as: employee_user),
        params: { user: valid_params.merge(email: new_email) }

      assert_response :redirect
      refute_nil flash[:success]
      assert_equal new_email, employee_user.reload.email
    end
  end

  describe '#chat_terms' do
    it_requires_authenticated_user { get chat_terms_url(@account_owner) }

    test 'it works' do
      get chat_terms_url(as: @account_owner)

      assert_response :success
      assert_template :chat_terms
    end
  end

  describe '#accept_chat_terms' do
    it_requires_authenticated_user { put chat_terms_url(@account_owner) }

    test 'it works' do
      put chat_terms_url(as: @account_owner)

      @account_owner.reload

      assert_redirected_to chat_url
      refute_nil @account_owner.chat_terms
      assert_includes @account_owner.chat_terms.keys, 'accepted_at'
      assert_includes @account_owner.chat_terms.keys, 'ip_address'
      refute_nil @account_owner.chat_terms['accepted_at']
      refute_nil @account_owner.chat_terms['ip_address']
    end
  end

  private

  def valid_params
    attributes_for(:user)
  end

  def invalid_params
    params = valid_params.clone
    params[:first_name] = ''
    params
  end
end
