class OfficePolicy < ApplicationPolicy
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
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def assign_admin?
    if user.super_admin?
      true
    elsif user.account_owner? && record_owned_by_account?
      true
    else
      false
    end
  end

  def remove_admin?
    if user.super_admin?
      true
    elsif user.account_owner? && record_owned_by_account?
      true
    else
      false
    end
  end

  # We don't know the document type in order to determine if it's confidential
  # and the current user has permission, e.g. office admin
  def new_document?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def create_document?
    default_permissions
  end

  def destroy?
    return false if record.employee_records.any?

    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def permitted_attributes
    permitted = [:account_id, :document_group_id, :name, :street_address, :address2,
                 :city, :state, :zip, :phone, :time_zone]

    if record.account_time_tracking
      permitted += [:tracks_time]
    end

    permitted
  end
end
