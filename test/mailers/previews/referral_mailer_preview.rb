# Preview all emails at http://localhost:3000/rails/mailers/accounts_mailer
class ReferralMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/accounts_mailer/account_owner_invite
  def new_referrals_email
    referrals = [
      Referral.new(name: 'John Doe', email: 'john@example.com'),
      Referral.new(name: 'Jane Doe', email: 'jane@example.com')
    ]
    user = User.first
    ReferralMailer.new_referrals_email(referrals, user)
  end

end
