# Preview all emails at http://localhost:3000/rails/mailers/accounts_mailer
class AccountsMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/accounts_mailer/account_owner_invite
  def account_owner_invite
    account = Account.last
    AccountsMailer.account_owner_invite(account)
  end

  def plan_upgrade_request
    account = Account.last
    AccountsMailer.plan_upgrade_request(account)
  end

end
