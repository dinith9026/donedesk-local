class AssignTrackToEmployeesForm < ApplicationForm
  attribute :notify_employees, Boolean, default: false
  attribute :employee_record_ids, Array

  validate :at_least_one_employee

  private

  def at_least_one_employee
    if employee_record_ids.reject(&:empty?).empty?
      errors.add(:base, 'You must select at least one employee')
    end
  end
end
