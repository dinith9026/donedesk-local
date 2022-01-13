class UserOfficesController < ApplicationController
  def create
    user = current_account.users.find(params[:user_id])
    authorize user, :assign_office?
    offices = current_account.offices.find(user_params[:office_ids])
    user.assigned_offices << offices
    user.save!

    set_flash_success_and_redirect_to(smart_back_path)
  end

  private

  def user_params
    params.require(:user).permit(office_ids: [])
  end
end
