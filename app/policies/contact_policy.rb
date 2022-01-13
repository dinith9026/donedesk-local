class ContactPolicy < ApplicationPolicy
  def index?
    default_permissions
  end

  def show?
    default_permissions
  end

  def new?
    default_permissions
  end

  def view?
    default_permissions
  end
end