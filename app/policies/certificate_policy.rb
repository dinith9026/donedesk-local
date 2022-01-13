class CertificatePolicy < ApplicationPolicy
  def show?
    if user.has_role?(:super_admin)
      true
    elsif user.account_admin? && user.account_employee_records.include?(record.employee_record)
      true
    elsif user.has_role?(:employee) && user.employee_record.id == record.employee_record.id
      true
    else
      false
    end
  end
end
