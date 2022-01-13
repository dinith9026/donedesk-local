class EmployeeRecordsPresenter < CollectionPresenter
  def when_employee_records_pending(&block)
    if account.pending_employee_records.count > 0
      yield
    end
  end

  def plan_max_employees
    account.plan_max_employees
  end

  def pending_employee_records
    account.pending_employee_records
  end

  def active
    EmployeeRecordsPresenter.new(
      account.active_employee_records,
      current_user
    )
  end

  def invites_remaining
    account.invites_remaining
  end

  def new_path
    new_employee_record_path
  end

  private

  def account_policy
    AccountPolicy.new(current_user, context.current_account)
  end

  def account
    context.current_account
  end
end
