require 'test_helper'

class ReferralMailerTest < ActionMailer::TestCase
  include ERB::Util

  test '#new_referrals_email' do
    referral1 = build(:referral)
    referral2 = build(:referral)
    referrals = [referral1, referral2]
    user = users(:account_owner)

    email = ReferralMailer.new_referrals_email(referrals, user)

    assert_emails(1) { email.deliver_now }
    assert_equal [Rails.configuration.donedesk.support_email], email.to
    assert_equal "New Referrals From: #{user.account_name}", email.subject
    assert_includes email.html_part.body.to_s, user.full_name
    assert_includes email.html_part.body.to_s, html_escape(referral1.name)
    assert_includes email.html_part.body.to_s, referral1.email
    assert_includes email.html_part.body.to_s, html_escape(referral2.name)
    assert_includes email.html_part.body.to_s, referral2.email
    assert_includes email.text_part.body.to_s, user.full_name
    assert_includes email.text_part.body.to_s, referral1.name
    assert_includes email.text_part.body.to_s, referral1.email
    assert_includes email.text_part.body.to_s, referral2.name
    assert_includes email.text_part.body.to_s, referral2.email
  end
end
