class UserPolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def show?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    elsif user.employee? && user.id == record.id
      true
    else
      false
    end
  end

  def edit?
    update?
  end

  def update?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    elsif user.employee? && user.id == record.id
      true
    else
      false
    end
  end

  def make_account_manager?
    default_permissions
  end

  def make_employee?
    default_permissions
  end

  def reinvite?
    default_permissions
  end

  def assign_office?
    if user.super_admin?
      true
    elsif user.account_owner? && record_owned_by_account?
      true
    else
      false
    end
  end

  def setup_2fa?
    record.two_factor_required? && !record.two_factor_setup?
  end

  def destroy?
    if record.employee_record.present?
      false
    else
      default_permissions
    end
  end

  def permitted_attributes
    permitted = [ :avatar, :email, :first_name, :last_name ]

    if user.has_role?(:super_admin)
      permitted << :two_factor_enabled
    end

    permitted.flatten
  end
end
