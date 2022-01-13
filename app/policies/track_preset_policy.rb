class TrackPresetPolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def new?
    create?
  end

  def create?
    user.super_admin?
  end

  def show?
    user.super_admin?
  end

  def edit?
    update?
  end

  def update?
    user.super_admin?
  end

  def copy?
    user.super_admin? || user.account_admin?
  end

  def reorder_courses?
    user.super_admin?
  end

  def destroy?
    user.super_admin?
  end
end
