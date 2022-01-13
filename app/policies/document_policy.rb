class DocumentPolicy < ApplicationPolicy
  def index?
    default_permissions
  end

  def show?
    raise "Not implemented"
  end

  def create?
    raise "Not implemented"
  end

  def update?
    raise "Not implemented"
  end

  def destroy?
    raise "Not implemented"
  end
end
