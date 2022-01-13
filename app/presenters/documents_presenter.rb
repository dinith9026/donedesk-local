class DocumentsPresenter < CollectionPresenter
  def employees(account)
    EmployeeRecordsPresenter.new(account.employee_records, current_user)
  end

  def offices(account)
    OfficesPresenter.new(account.offices, current_user)
  end
end
