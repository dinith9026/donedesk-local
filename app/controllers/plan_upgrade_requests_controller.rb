class PlanUpgradeRequestsController < ApplicationController
  before_action :skip_authorization, only: :create

  def create
    AccountsMailer.plan_upgrade_request(current_account).deliver_later
    flash[:success] = 'Your request has been sent. We will contact you shortly.'
    redirect_back(fallback_location: dashboard_path)
  end
end
