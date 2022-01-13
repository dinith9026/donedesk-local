class PTOEntriesPresenter < CollectionPresenter
  DEFAULT_DATE_FORMAT = '%a, %b %-e, %Y'

  def active_employee_records
    employee_records = context.current_account.active_employee_records
    EmployeeRecordsPresenter.new(employee_records, current_user)
  end

  def date_from(format = DEFAULT_DATE_FORMAT)
    context&.date_range.begin.to_date.strftime(format)
  end

  def date_to(format = DEFAULT_DATE_FORMAT)
    context&.date_range.end.to_date.strftime(format)
  end
end
