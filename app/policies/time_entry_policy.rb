class TimeEntryPolicy < ApplicationPolicy
  def new?
     user.super_admin? || user.account_admin?
  end

  def create?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    elsif user.employee? && user.employee_record_id == record.employee_record_id
      true
    else
      false
    end
  end

  def destroy?
    user.super_admin? || user.account_admin?
  end

  def permitted_attributes
    permitted = [:entry_type]

    if user.super_admin? || user.account_admin?
      permitted += [:employee_record_id, :occurred_at]
    end

    permitted
  end
end
