require 'test_helper'

class RegistrationMailerTest < ActionMailer::TestCase
  test '#account_owner_welcome_email' do
    account_owner = users(:invited_account_owner)
    host = ActionMailer::Base.default_url_options[:host]
    sign_in_url = "http://#{host}/sign_in"

    email = RegistrationMailer.account_owner_welcome_email(account_owner)

    assert_emails(1) { email.deliver_now }
    assert_equal [account_owner.email], email.to
    assert_equal 'Welcome to DoneDesk', email.subject
    assert_select_email { assert_select 'a', 'Sign in now' }
    assert_includes email.html_part.body.to_s, sign_in_url
    assert_includes email.text_part.body.to_s, sign_in_url
  end
end
