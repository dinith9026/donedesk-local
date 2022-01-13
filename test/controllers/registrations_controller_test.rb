require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @account = accounts(:invited)
    @user = users(:invited_account_owner)
  end

  describe '#new' do
    test 'when invite_token is invalid' do
      invite_token = 'invalid'

      get new_registration_url(invite_token: invite_token)

      assert_redirected_to '/404'
    end

    test 'when invite_token is valid' do
      get new_registration_url(invite_token: @account.invite_token)

      assert_response :success
      assert_template :new
      refute_nil assigns[:form]
      assert_equal @account.invite_token, assigns[:account].invite_token
    end
  end

  describe '#create' do
    test 'when invite token is invalid' do
      post registrations_url(invite_token: 'invalid'),
              params: { registration: valid_params }

      assert_redirected_to '/404'
    end

    describe 'when invite token is valid' do
      test 'when params are invalid' do
        old_encrypted_password = @user.encrypted_password

        perform_enqueued_jobs do
          post registrations_url(invite_token: @account.invite_token),
                params: { registration: invalid_params }
        end

        assert_response :success
        assert_template :new
        refute_nil assigns[:form]
        refute_nil assigns[:account]
        assert_equal @account.invite_token, assigns[:account].invite_token
        assert_equal old_encrypted_password, @user.reload.encrypted_password
        assert_empty ActionMailer::Base.deliveries
        refute_nil @account.reload.invite_token
      end

      test 'when params are valid but card is declined' do
        old_encrypted_password = @user.encrypted_password

        StripeMock.prepare_card_error(:card_declined, :new_customer)

        assert_no_difference 'ActionMailer::Base.deliveries.size' do
          perform_enqueued_jobs do
            post registrations_url(invite_token: @account.invite_token),
                  params: { registration: valid_params }
          end
        end
        assert_response :success
        refute_nil flash[:error]
        assert_equal old_encrypted_password, @user.reload.encrypted_password
        refute_nil @account.reload.invite_token
        assert_nil @account.stripe_customer_id
        assert_nil @account.stripe_subscription_id
      end

      test 'when params are valid' do
        old_encrypted_password = @user.encrypted_password

        perform_enqueued_jobs do
          post registrations_url(invite_token: @account.invite_token),
                params: { registration: valid_params }
        end

        assert_redirected_to dashboard_url
        refute_nil flash[:success]
        refute_equal old_encrypted_password, @user.reload.encrypted_password
        assert_match(/welcome to donedesk/i, last_email.subject)
        assert_nil @account.reload.invite_token
        refute_nil @account.stripe_customer_id
        refute_nil @account.stripe_subscription_id
      end
    end
  end

  private

  def valid_params
    {
      password: default_password,
      password_confirmation: default_password,
      terms: '1',
      stripe_token: stripe_card_token,
    }
  end

  def invalid_params
    {
      password: '',
      password_confirmation: '',
      terms: '',
    }
  end
end
