class OfficePresenter < ModelPresenter
  presents :office

  delegate :name, :phone, :street_address, :address2, :city, :state, :zip, :time_zone,
    :document_compliance_percentage, :training_compliance_percentage, :active_admins, :document_group_name,
    :document_types_groupings, :documents,
    to: :office

  def employee_records_presenter
    context[:employee_records_presenter]
  end

  def documents_presenter
    DocumentsPresenter.new(office.office_documents, current_user)
  end

  def documents_status_listing
    office.document_types_groupings.sort_by(&:document_type_name).map do |document_types_grouping|
      document_status = DocumentStatus.new(office, document_types_grouping, office.office_documents)
      presenter_for(document_status)
    end
  end

  def when_time_tracking_enabled_for_account(&block)
    yield if office.account_time_tracking
  end

  def tracks_time?
    if office.tracks_time
      'Yes'
    else
      'No'
    end
  end

  def col_classes
    if user_can?(:assign_admin)
      'col-md-12 col-lg-6'
    else
      'col-sm-12'
    end
  end

  def employed_employees_count
    office.employed_employees.count
  end

  def unassigned_admins
    office.account_active_users.order(:last_name).account_manager - office.active_admins
  end

  def show_path
    office_path(office)
  end

  def edit_path
    edit_office_path(office)
  end

  def document_group_show_path
    document_group_path(office.document_group)
  end

  def new_document_path(document_type_id = nil)
    new_office_document_path(office, document_type_id: document_type_id)
  end

  def users_path
    office_users_path(office_id: office)
  end

  def user_path(user)
    office_user_path(office, user)
  end
end
