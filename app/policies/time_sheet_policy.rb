class TimeSheetPolicy < ApplicationPolicy
  def index?
    if (user.super_admin? || user.account_admin?) && account.time_tracking
      true
    elsif user.employee?
      false
    else
      false
    end
  end
end
