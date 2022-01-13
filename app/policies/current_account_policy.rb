class CurrentAccountPolicy < ApplicationPolicy
  def update?
    user.super_admin?
  end
end
