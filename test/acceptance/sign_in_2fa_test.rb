require 'test_helper'

class SignIn2faTest < AcceptanceTestCase
  test 'when 2FA is enabled for user but not setup' do
    user = users(:account_owner)
    enable_two_factor!(user)

    visit '/sign_in'
    assert_content I18n.t('sessions.new.sign_in')

    fill_in 'session_email', with: user.email
    fill_in 'session_password', with: default_password
    click_button I18n.t('sessions.new.sign_in')

    assert_content 'Setup Two-Factor Authentication'

    user.reload

    fill_in 'two_fa_code', with: user.otp_code
    fill_in 'two_fa_password', with: default_password
    click_button 'Setup 2FA'

    assert_content I18n.t('layouts.application.sign_out')
  end

  test 'when 2FA setup is canceled' do
    user = users(:account_owner)
    enable_two_factor!(user)

    visit '/sign_in'
    assert_content I18n.t('sessions.new.sign_in')

    fill_in 'session_email', with: user.email
    fill_in 'session_password', with: default_password
    click_button I18n.t('sessions.new.sign_in')

    assert_content 'Setup Two-Factor Authentication'

    user.reload

    visit '/dashboard'

    assert_content 'Setup Two-Factor Authentication'
  end

  test 'when 2FA is enabled AND setup' do
    user = users(:account_owner)
    enable_two_factor!(user)
    user.two_factor_setup!
    user.generate_two_factor_secret_if_missing!

    visit '/sign_in'
    assert_content I18n.t('sessions.new.sign_in')

    fill_in 'session_email', with: user.email
    fill_in 'session_password', with: default_password
    click_button I18n.t('sessions.new.sign_in')

    assert_content I18n.t('sessions.new.two_factor_auth')

    user.reload

    fill_in 'session_otp_attempt', with: user.otp_code
    click_button I18n.t('sessions.new.sign_in')

    assert_content I18n.t('layouts.application.sign_out')
  end
end
