class DocumentGroupPolicy < ApplicationPolicy
  def assign?
    user.super_admin? || user.account_admin?
  end

  def copy?
    user.super_admin? || user.account_admin?
  end

  def reassign?
    user.super_admin? || user.account_admin?
  end

  def destroy?
    (user.super_admin? || user.account_admin?)
  end
end
