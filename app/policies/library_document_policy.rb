class LibraryDocumentPolicy < ApplicationPolicy
  def index?
    true
  end

  def update?
    if user.has_role?(:super_admin)
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def show?
    if user.has_role?(:super_admin)
      true
    elsif user.account_admin? && (record.is_canned? || record_owned_by_account?)
      true
    elsif user.employee? && (record.is_canned? || record_owned_by_account?) && record.is_visible_to_employees
      true
    else
      false
    end
  end

  def download?
    if user.has_role?(:super_admin)
      true
    elsif user.account_admin? && (record.is_canned? || record_owned_by_account?)
      true
    elsif user.employee? && (record.is_canned? || record_owned_by_account?) && record.is_visible_to_employees
      true
    else
      false
    end
  end

  def destroy?
    if user.has_role?(:super_admin)
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def view_disclaimer?
    default_permissions
  end

  def permitted_attributes
    permitted = [:name, :summary]

    if user.super_admin? || user.account_admin?
      permitted << [:account_id, :file, :is_visible_to_employees, :created_at, :type]
    end

    if user.super_admin?
      permitted << :is_canned
    end

    permitted.flatten
  end
end
