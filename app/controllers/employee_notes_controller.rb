class EmployeeNotesController < ApplicationController
  def new
    employee_record = find_employee_record
    @form = EmployeeNoteForm.new
            .with_policy(policy(EmployeeNote.new))
            .with_context(current_account: current_account, employee_record: employee_record)
    authorize employee_record, :create_employee_note?
  end

  def create
    employee_record = find_employee_record
    @form = EmployeeNoteForm
            .from_params(employee_note_params, creator_id: current_user.id)
            .with_context(current_account: current_account, employee_record: employee_record)
    authorize employee_record, :create_employee_note?

    if @form.valid?
      employee_record.employee_notes.create(@form.attributes)
      set_flash_success_and_redirect_to(smart_back_path)
    else
      render :new
    end
  end

  private

  def find_employee_record
    current_account.employee_records.find(params[:employee_record_id])
  end

  def employee_note_params
    params.require(:employee_note).permit(:body)
  end
end
