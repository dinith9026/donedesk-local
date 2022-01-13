class SubmitReferrals < ApplicationCommand
  def initialize(referrals, from_user)
    @referrals = referrals
    @from_user = from_user
  end

  def call
    invalid_referrals = @referrals.select do |referral|
      !referral.valid?
    end

    if @referrals.none? || invalid_referrals.any?
      broadcast(:invalid)
    else
      ReferralMailer.new_referrals_email(@referrals, @from_user).deliver_now
      broadcast(:ok)
    end
  end
end
