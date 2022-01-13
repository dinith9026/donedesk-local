class OfficeDocumentPolicy < ApplicationPolicy
  def index?
    default_permissions
  end

  def show?
    if user.super_admin?
      true
    elsif user.account_owner? && record_owned_by_account?
      true
    elsif record_owned_by_account? && ((!record.is_confidential && user.account_manager?) ||
        (record.is_confidential && record.office.is_admin?(user)))
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
    elsif user.account_owner? && record_owned_by_account?
      true
    elsif record_owned_by_account? && ((!record.is_confidential && user.account_manager?) ||
        (record.is_confidential && record.office.is_admin?(user)))
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
    elsif user.account_owner? && record_owned_by_account?
      true
    elsif record_owned_by_account? && ((!record.is_confidential && user.account_manager?) ||
        (record.is_confidential && record.office.is_admin?(user)))
      true
    else
      false
    end
  end

  def download?
    if user.super_admin?
      true
    elsif user.account_owner? && record_owned_by_account?
      true
    elsif record_owned_by_account? && ((!record.is_confidential && user.account_manager?) ||
        (record.is_confidential && record.office.is_admin?(user)))
      true
    else
      false
    end
  end

  def view_history?
    if user.super_admin?
      true
    elsif user.account_owner? && record_owned_by_account?
      true
    elsif record_owned_by_account? && ((!record.is_confidential && user.account_manager?) ||
          (record.is_confidential && record.office_is_admin?(user)))
      true
    else
      false
    end
  end

  def destroy?
    if user.super_admin?
      true
    elsif user.account_owner? && record_owned_by_account?
      true
    elsif record_owned_by_account? && ((!record.is_confidential && user.account_manager?) ||
          (record.is_confidential && record.office.is_admin?(user)))
      true
    else
      false
    end
  end
end
