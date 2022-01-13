class DashboardPolicy < ApplicationPolicy
  def show?
    default_permissions || user.has_role?(:employee)
  end
end
