class ExamPolicy < ApplicationPolicy
  def show?
    (user.has_role?(:employee) || user.has_role?(:account_manager)) &&
      record_owned_by_user?
  end

  private

  def record_owned_by_user?
    record.employee_record_id == user.employee_record_id
  end
end
