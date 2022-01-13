# Preview all emails at http://localhost:3000/rails/mailers/registration_mailer
class RegistrationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/registration_mailer/account_owner_welcome_email
  def account_owner_welcome_email
    account_owner = Account.last.owner
    RegistrationMailer.account_owner_welcome_email(account_owner)
  end

end
