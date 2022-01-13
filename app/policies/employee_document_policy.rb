class EmployeeDocumentPolicy < DocumentPolicy
  def index?
    default_permissions
  end

  def show?
    if user.super_admin?
      true
    elsif user.account_owner? && record_owned_by_account?
      true
    elsif record_owned_by_account? && ((!record.is_confidential && user.account_manager?) ||
        (record.is_confidential && record.employee_record_office.is_admin?(user) && !is_confidential_document_for_account_manager?))
      true
    elsif user.employee? && !record.is_confidential && record_belongs_to_user
      true
    else
      false
    end
  end

  def new?
    create?
  end

  def create?
    return true if record.document_type.nil? || record.employee_record.nil?
    return true if user.super_admin? || user.account_owner?

    if user.super_admin?
      true
    elsif user.account_owner? && record_owned_by_account?
      true
    elsif record_owned_by_account? && ((!record.is_confidential && user.account_manager?) ||
        (record.is_confidential && record.employee_record_office.is_admin?(user) && !is_confidential_document_for_account_manager?))
      true
    elsif user.employee? && !record.is_confidential && record_belongs_to_user
      true
    else
      false
    end
  end

  def update?
    if user.employee?
      false
    elsif user.super_admin?
      true
    elsif user.account_owner? && record_owned_by_account?
      true
    elsif record_owned_by_account? && ((!record.is_confidential && user.account_manager?) ||
        (record.is_confidential && record.employee_record_office.is_admin?(user) && !is_confidential_document_for_account_manager?))
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
        (record.is_confidential && record.employee_record_office.is_admin?(user) && !is_confidential_document_for_account_manager?))
      true
    elsif user.employee? && !record.is_confidential && record_belongs_to_user
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
        (record.is_confidential && record.employee_record_office.is_admin?(user)))
      true
    elsif user.employee? && !record.is_confidential && record_belongs_to_user
      true
    else
      false
    end
  end

  def destroy?
    if user.employee?
      false
    elsif user.super_admin?
      true
    elsif user.account_owner? && record_owned_by_account?
      true
    elsif record_owned_by_account? && ((!record.is_confidential && user.account_manager?) ||
        (record.is_confidential && record.employee_record_office.is_admin?(user) && !is_confidential_document_for_account_manager?))
      true
    else
      false
    end
  end

  private

  def record_belongs_to_user
    user.employee_record_id == record.employee_record_id
  end

  def is_confidential_document_for_account_manager?
    record.document_type.is_confidential? && record_belongs_to_user
  end
end
