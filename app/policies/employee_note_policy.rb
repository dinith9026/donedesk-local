class EmployeeNotePolicy < ApplicationPolicy
  def index?
    default_permissions
  end

  def new?
    create?
  end

  def create?
    default_permissions
  end

  def edit?
    update?
  end

  def update?
    false
  end

  def destroy?
    false
  end
end
