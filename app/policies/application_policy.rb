class ApplicationPolicy
  attr_reader :context, :record, :user, :account

  def initialize(context, record)
    @context = context
    @record = record
    @user = context.try(:user) || context
    @account = context.try(:account) if context.present?
  end

  def index?
    default_permissions
  end

  def show?
    default_permissions
  end

  def create?
    default_permissions
  end

  def new?
    create?
  end

  def update?
    default_permissions
  end

  def edit?
    update?
  end

  def user_role
    user.role.to_sym
  end

  def record_owned_by_account?
    record.account_id == user.account_id
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def default_permissions
    user.super_admin? || user.account_owner? || user.account_manager?
  end
end
