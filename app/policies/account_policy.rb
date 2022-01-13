class AccountPolicy < ApplicationPolicy
  def index?
    if user.super_admin?
      true
    else
      false
    end
  end

  def new?
    create?
  end

  def create?
    if user.super_admin?
      true
    else
      false
    end
  end

  def show?
    if user.super_admin?
      true
    else
      false
    end
  end

  def edit?
    update?
  end

  def update?
    if user.super_admin? && record.active?
      true
    else
      false
    end
  end

  def new_office?
    if user.super_admin? && record.active?
      true
    else
      false
    end
  end

  def new_plan?
    if user.super_admin? && record.active? && record.invite_accepted?
      true
    else
      false
    end
  end

  def create_employee_record?
    return false if record.plan_max_employees_reached?

    if user.super_admin? || user.account_admin?
      true
    elsif user.employee? && user.employee_record.blank?
      true
    else
      false
    end
  end

  def reinvite?
    if user.super_admin? && record.active? && !record.invite_accepted?
      true
    else
      false
    end
  end

  def deactivate?
    if user.super_admin? && record.active?
      true
    else
      false
    end
  end

  def reactivate?
    if user.super_admin? && record.deactivated?
      true
    else
      false
    end
  end
end
