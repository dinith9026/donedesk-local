class DoneDesk::Presenters::OwnerDashboard
  attr_reader :current_user

  def initialize(current_user:)
    @current_user = current_user
  end

  def max_employees
    current_user.account.plan.max_employees
  end
end
