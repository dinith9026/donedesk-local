class EmployeeRecordPolicy < ApplicationPolicy
  def show?
    if user.has_role?(:employee)
      record.id == user.employee_record_id
    else
      default_permissions
    end
  end

  def update?
    if user.has_role?(:employee)
      record.id == user.employee_record_id
    else
      default_permissions
    end
  end

  def assign_course?
    default_permissions && record.employed?
  end

  def assign_track?
    default_permissions && record.employed?
  end

  def take_assignments?
    (user.has_role?(:employee) || user.has_role?(:account_manager)) &&
      user.employee_record == record
  end

  def list_documents?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    elsif user.employee? && record_belongs_to_user
      true
    else
      false
    end
  end

  def list_time_cards?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    elsif user.employee? && record_belongs_to_user
      true
    else
      false
    end
  end

  def list_time_entries?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    elsif user.employee? && record_belongs_to_user
      true
    else
      false
    end
  end

  def list_employee_notes?
    if user.super_admin?
      true
    elsif user.account_owner? && record_owned_by_account?
      true
    elsif user.account_manager? && record_owned_by_account? && !record_belongs_to_user
      true
    else
      false
    end
  end

  def list_assigned_offices?
    if user.super_admin? && record.has_login? && record.user_account_manager?
      true
    elsif user.account_owner? && record_owned_by_account? && record.has_login? && record.user_account_admin?
      true
    else
      false
    end
  end

  def new_time_entry?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def suspend?
    default_permissions && record.employed?
  end

  def unsuspend?
    default_permissions && record.suspended?
  end

  def terminate?
    default_permissions && !record.terminated?
  end

  def rehire?
    default_permissions && record.terminated?
  end

  def new_document?
    if user.has_role?(:employee)
      record.id == user.employee_record_id
    else
      default_permissions
    end
  end

  def create_employee_note?
    if user.super_admin?
      true
    elsif user.account_owner? && record_owned_by_account?
      true
    elsif user.account_manager? && record_owned_by_account? && !record_belongs_to_user
      true
    else
      false
    end
  end

  def invite?
    default_permissions && record.user.blank? && record.employed?
  end

  def permitted_attributes
    permitted = [
      :user_id, :office_id, :first_name, :last_name, :title, :dob,
      :phone, :address, :marital_status, :employment_type,
      :emergency_contact_name, :emergency_contact_relationship,
      :emergency_contact_phone, :emergency_contact_email, :agd_member_number
    ]

    if user.has_role?(:super_admin) || user.account_admin?
      permitted << :hired_on
      permitted << :terminated_on
      permitted << :document_group_id
      permitted << { track_ids: [] }
    end

    permitted <<  { user: [ :avatar, :email, :role, :first_name, :last_name ] }

    permitted.flatten
  end

  private

  def record_belongs_to_user
    record.user_id == user.id
  end
end
