class InvitesController < ApplicationController
  def new
    employee_record = find_employee_record
    authorize employee_record, :invite?
    @form = InviteForm.new.with_context(employee_record: employee_record)
  end

  def create
    employee_record = find_employee_record
    authorize employee_record, :invite?
    @form = InviteForm.from_params(invite_params).with_context(employee_record: employee_record)

    InviteEmployee.call(current_account, employee_record, @form) do
      on(:ok)      { set_flash_success_and_redirect_to(employee_records_url) }
      on(:invalid) { set_flash_error_and_render(:new) }
    end
  end

  private

  def find_employee_record
    current_account.employee_records.find(params[:employee_record_id])
  end

  def invite_params
    params.require(:invite).permit(:email, :role)
  end
end
