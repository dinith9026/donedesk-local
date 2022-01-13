class TrackPolicy < ApplicationPolicy
  def show?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def update?
    if record.deactivated?
      false
    elsif user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def assign?
    if record.deactivated?
      false
    elsif user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def unassign?
    if record.deactivated?
      false
    elsif user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def add_course?
    if record.deactivated?
      false
    elsif user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def reorder_courses?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def remove_course?
    if record.deactivated? || record.courses.size == 1
      false
    elsif user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def destroy?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def deactivate?
    if record.deactivated?
      false
    elsif user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def reactivate?
    if record.active?
      false
    elsif user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end
end
