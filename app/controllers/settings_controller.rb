class SettingsController < ApplicationController
  def update
    authorize current_user
    current_user.update!(settings_params)

    head :no_content
  end

  private

  def settings_params
    params.require(:settings).permit(:send_compliance_summary_email)
  end
end
