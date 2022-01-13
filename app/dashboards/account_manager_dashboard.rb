class AccountManagerDashboard < AccountAdminsDashboard
  def when_employee_record_exists(&block)
    if @user.employee_record.present?
      yield
    end
  end

  def when_no_employee_record_exists(&block)
    unless @user.employee_record.present?
      yield
    end
  end

  def new_employee_record_form
    policy = EmployeeRecordPolicy.new(@user, EmployeeRecord.new)

    EmployeeRecordForm.new
      .with_policy(policy)
      .with_context(current_account: @user.account)
  end
end
