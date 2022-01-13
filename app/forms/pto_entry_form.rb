class PTOEntryForm < ApplicationForm
  attribute :employee_record_id, String
  attribute :hours, Float
  attribute :date, Date

  include CommonPTOEntryValidations

  def employee_record_full_name
    employee_record.full_name
  end

  def formatted_date
    date.presence&.strftime('%m/%d/%Y')
  end

  def new_form_action
    employee_record_pto_entries_path(context.employee_record)
  end

  def edit_form_action
    pto_entry_path(id)
  end

  private

  def employee_record
    context.employee_record
  end
end
