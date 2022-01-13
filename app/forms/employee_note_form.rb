class EmployeeNoteForm < ApplicationForm
  attribute :creator_id, String
  attribute :body, String

  include CommonEmployeeNoteValidations

  def employee_notes_path
    employee_record_employee_notes_path(employee_record)
  end

  def employee_record_full_name
    employee_record.full_name
  end

  def employee_record
    context&.employee_record
  end

  def current_account
    context&.current_account
  end
end
