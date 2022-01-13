class OfficeUsersController < ApplicationController
  def create
    office = current_account.offices.find(params[:office_id])
    authorize office, :assign_admin?
    users = current_account.users.find(office_params[:user_ids])
    office.admins << users
    office.save!

    set_flash_success_and_redirect_to(office)
  end

  def destroy
    office = current_account.offices.find(params[:office_id])
    user = current_account.users.find(params[:id])
    authorize office, :remove_admin?

    OfficesUser.find_by!(office_id: office.id, user_id: user.id).destroy!

    set_flash_success_and_redirect_to(smart_back_path)
  end

  private

  def office_params
    params.require(:office).permit(user_ids: [])
  end
end
