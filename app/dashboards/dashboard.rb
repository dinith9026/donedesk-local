module Dashboard
  def self.for(user)
    case user.role.to_s
    when 'super_admin'
      SuperAdminDashboard.new
    when 'account_owner'
      AccountOwnerDashboard.new(user)
    when 'account_manager'
      AccountManagerDashboard.new(user)
    when 'employee'
      EmployeeDashboard.new(user)
    end
  end
end
