class DocumentGroupPresenter < ModelPresenter
  presents :document_group

  delegate :name, :applies_to, :employee_records, :offices, :document_types_groupings, to: :document_group

  def applies_to_count
    if applies_to == 'employees'
      active_employee_records.size
    else
      offices.size
    end
  end

  def active_employee_records
    employee_records.select(&:employed?)
  end

  def unassigned_employees_grouped_by_title
    EmployeeRecordsPresenter.new(context[:unassigned_employees], current_user).group_by do |erp|
      erp.title
    end.sort_by { |k, v| k }.to_h
  end

  def unassigned_offices
    OfficesPresenter.new(context[:unassigned_offices], current_user)
  end

  def show_path
    document_group_path(document_group)
  end

  def edit_path
    edit_document_group_path(document_group)
  end

  def copy_path
    copy_document_group_path(document_group)
  end

  def reassign_path
    reassign_document_group_path(document_group)
  end

  def destroy_path
    document_group_path(document_group)
  end
end
