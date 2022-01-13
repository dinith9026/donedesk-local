class DocumentTypePolicy < ApplicationPolicy
  def update?
    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def destroy?
    return false if record.documents.any?

    if user.super_admin?
      true
    elsif user.account_admin? && record_owned_by_account?
      true
    else
      false
    end
  end

  def permitted_attributes
    return [] if user.employee?

    permitted = [:name, :applies_to]

    if user.super_admin?
      permitted << :is_canned
    end

    if user.super_admin? || user.account_owner?
      permitted << :is_confidential
    end

    permitted
  end
end
