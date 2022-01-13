require 'test_helper'

class AccountsMailerTest < ActionMailer::TestCase
  test '#account_owner_invite' do
    account = build(:account, :invited)
    registration_link = new_registration_path(invite_token: account.invite_token)

    email = AccountsMailer.account_owner_invite(account)

    assert_emails(1) { email.deliver_now }
    assert_equal [account.owner_email], email.to
    assert_match(/Invite: #{account.name} DoneDesk/i, email.subject)
    assert_includes email.html_part.body.to_s, registration_link
    assert_includes email.text_part.body.to_s, registration_link
  end

  test '#plan_upgrade_request' do
    account = build(:account, id: SecureRandom.uuid)
    account_link = account_path(account)

    email = AccountsMailer.plan_upgrade_request(account)

    assert_emails(1) { email.deliver_now }
    assert_equal [Rails.configuration.donedesk.support_email], email.to
    assert_match(/Plan Upgrade Request for #{account.name}/i, email.subject)
    assert_includes email.html_part.body.to_s, account_link
    assert_includes email.text_part.body.to_s, account_link
  end
end
