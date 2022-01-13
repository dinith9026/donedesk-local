class ReferralMailer < ApplicationMailer
  layout 'mailer'

  def new_referrals_email(referrals, from_user)
    @referrals = referrals
    @from_user = from_user
    mail(to: support_email, subject: "New Referrals From: #{from_user.account_name}")
  end
end
