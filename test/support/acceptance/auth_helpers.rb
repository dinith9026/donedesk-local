module Acceptance
  module AuthHelpers
    include TestPasswordHelper

    def sign_in_with(user, password = default_password)
      # user.generate_two_factor_secret_if_missing!

      visit '/sign_in'
      assert_content I18n.t('sessions.new.sign_in')

      fill_in 'session_email', with: user.email
      fill_in 'session_password', with: password
      click_button I18n.t('sessions.new.sign_in')
      # assert_content I18n.t('sessions.new.two_factor_auth')

      # fill_in 'session_otp_attempt', with: user.otp_code
      # click_button I18n.t('sessions.new.sign_in')

      assert_content I18n.t('layouts.application.sign_out')
    end
  end
end
