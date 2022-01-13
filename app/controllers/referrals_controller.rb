class ReferralsController < ApplicationController
  def create
    authorize Referral

    SubmitReferrals.call(referrals_from_params, current_user) do
      on(:ok)      { respond_with_result('success') }
      on(:invalid) { respond_with_result('failure') }
    end
  end

  private

  def referrals_params
    params.permit(referrals: [:name, :email])
  end

  def referrals_from_params
    referrals_params[:referrals].map do |referral_params|
      Referral.new(referral_params)
    end.select do |referral|
      referral.valid?
    end
  end

  def respond_with_result(result)
    @result = result
    respond_to do |format|
      format.js
    end
  end
end
