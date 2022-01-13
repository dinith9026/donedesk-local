class EmployeeDocumentPresenter < ModelPresenter
  presents :employee_document

  delegate :summary, :file_name, :employee_record_full_name, :document, to: :employee_document

  def document_presenter
    presenter_for(employee_document.document).with_context(belongs_to: employee_document)
  end

  def when_user_can_manage(&block)
    if user_can_manage?
      yield
    end
  end

  def user_can_manage?
    user_can?(:edit) || user_can?(:download) || user_can?(:destroy)
  end

  def belongs_to_name
    name
  end

  def name
    document_presenter.name
  end

  def expires_on
    if document.expirable?
      I18n.localize(document.expires_on.to_date, format: :default)
    else
      ''
    end
  end

  def created_at
    I18n.localize(document.created_at.to_date, format: :default)
  end

  def show_employee_record_path
    employee_record_path(employee_document.employee_record)
  end

  def edit_path
    edit_employee_document_path(employee_document)
  end

  def download_path
    download_employee_document_path(employee_document.id)
  end

  def destroy_path
    employee_document_path(employee_document)
  end
end
