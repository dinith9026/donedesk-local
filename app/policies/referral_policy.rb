class ReferralPolicy < ApplicationPolicy
  def create?
    if user.has_role?(:super_admin)
      false
    elsif user.has_role?(:account_owner) || user.has_role?(:account_manager) || user.has_role?(:employee)
      true
    else
      false
    end
  end
end
