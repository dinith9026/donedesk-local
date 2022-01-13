class TimeEntriesPresenter < CollectionPresenter
  def active_employee_records
    employee_records = context.current_account.active_employee_records
    EmployeeRecordsPresenter.new(employee_records, current_user)
  end

  def date
    context.date.strftime('%A, %B %e, %Y')
  end

  def date_param
    context.date.strftime('%Y-%m-%d')
  end

  def when_user_can_manage_entries
    yield if current_user.super_admin? || current_user.account_admin?
  end

  def new_path
    new_employee_record_time_entry_path(context.employee_record)
  end
end
