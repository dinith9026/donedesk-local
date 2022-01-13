class AssignmentPolicy < ApplicationPolicy
  def index?
    return false unless user.employee_record.present?

    user.has_role?(:employee) || user.has_role?(:account_manager)
  end

  def take_exam?
    (user.has_role?(:employee) || user.has_role?(:account_manager)) &&
      user.employee_record_assignments.include?(record) &&
      record.exam_takeable?
  end

  def mark_completed?
    if record.passed?
      false
    elsif user.has_role?(:super_admin)
      true
    elsif user.account_admin? && record_belongs_to_account
      true
    else
      false
    end
  end

  def show?
    user.has_role?(:employee) || user.has_role?(:account_manager)
  end

  def download?
    user.has_role?(:employee) || user.has_role?(:account_manager)
  end

  def destroy?
    default_permissions && !record.course_belongs_to_assigned_track?
  end

  private

  def record_belongs_to_account
    record.employee_record.account_id == user.account_id
  end
end
