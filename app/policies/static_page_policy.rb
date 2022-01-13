class StaticPagePolicy < ApplicationPolicy
  def insurance?
    default_permissions
  end

  def payroll?
    default_permissions
  end

  def background_check?
    default_permissions
  end

  def compliance_coaching?
    default_permissions
  end

  def hr_coaching?
    default_permissions
  end

  def health_insurance_coaching?
    default_permissions
  end

  def terms?
    default_permissions || user.has_role?(:employee)
  end

  def privacy_policy?
    default_permissions || user.has_role?(:employee)
  end

  def logout_or_continue?
    default_permissions || user.has_role?(:employee)
  end
end
