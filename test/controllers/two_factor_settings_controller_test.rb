require 'test_helper'

class TwoFactorSettingsControllerTest < ActionDispatch::IntegrationTest
  describe 'new' do
    [:super_admin, :account_owner, :account_manager, :employee].each do |role|
      describe "for #{role}" do
        test 'when 2FA is required and NOT set up' do
          user = users(role)
          enable_two_factor!(user)

          get new_two_factor_settings_url(as: user)

          assert_response :ok
          assert_template :new
        end
      end
    end
  end

  describe 'create' do
    [:super_admin, :account_owner, :account_manager, :employee].each do |role|
      describe "for #{role}" do
        test 'when password is invalid and code is valid' do
          user = users(role)
          user.generate_two_factor_secret_if_missing!
          enable_two_factor!(user)
          params = {
            code: user.otp_code,
            password: 'invalid'
          }

          post two_factor_settings_url(as: user, params: { two_fa: params })

          assert_response :ok
          assert_template :new
          refute_nil flash[:alert]
          assert_equal flash[:alert], 'Incorrect password'
        end

        test 'when password is valid and code is invalid' do
          user = users(role)
          user.generate_two_factor_secret_if_missing!
          enable_two_factor!(user)
          params = {
            code: 'invalid',
            password: default_password
          }

          post two_factor_settings_url(as: user, params: { two_fa: params })

          assert_response :ok
          assert_template :new
          refute_nil flash[:alert]
          assert_equal flash[:alert], 'Incorrect code'
        end

        test 'when password and code are valid' do
          user = users(role)
          user.generate_two_factor_secret_if_missing!
          enable_two_factor!(user)
          params = {
            code: user.otp_code,
            password: default_password
          }

          post two_factor_settings_url(as: user, params: { two_fa: params })

          assert_redirected_to root_path
          refute_nil flash[:notice]
          assert_equal flash[:notice], 'Successfully set up two-factor authentication!'
        end
      end
    end
  end
end
