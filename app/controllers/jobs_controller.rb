class JobsController < ApplicationController
  before_action :skip_authorization, only: [:create]

  def create
    job = params[:job]
    account = current_user.account

    if allowed_jobs.include?(job.to_s)
      account.update!(is_calculating_compliance_stats: true)
      CalculateComplianceStatsJob.perform_later(account.id)
      set_flash_success_and_redirect_to(dashboard_path, 'Calculating stats...it should only take a few minutes!')
    else
      set_flash_error_and_redirect_to(dashboard_path, 'Unauthorized')
    end
  end

  def allowed_jobs
    ['calculate_compliance_stats']
  end
end
