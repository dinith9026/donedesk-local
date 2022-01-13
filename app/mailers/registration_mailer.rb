class RegistrationMailer < ApplicationMailer
  layout 'mailer'

  def account_owner_welcome_email(account_owner)
    @account_owner = account_owner
    mail(to: @account_owner.email, subject: 'Welcome to DoneDesk')
  end
end
