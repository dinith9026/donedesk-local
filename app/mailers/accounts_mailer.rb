class AccountsMailer < ApplicationMailer
  layout 'mailer'

  def account_owner_invite(account)
    @owner_first_name = account.owner_first_name
    @invite_token = account.invite_token
    mail(to: account.owner_email, subject: "Invite: #{account.name} DoneDesk")
  end

  def plan_upgrade_request(account)
    @account = account
    mail(
      to: Rails.configuration.donedesk.support_email,
      subject: "Plan Upgrade Request for #{account.name}")
  end
end
