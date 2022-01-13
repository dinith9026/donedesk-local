class OfficeDocumentPresenter < ModelPresenter
  presents :office_document

  delegate :document, :summary, :office_name, :file_name, :created_at, :expiration, to: :office_document

  def belongs_to_name
    office_document.office_name
  end

  def employee_record_full_name
    office_document.office.name
  end

  def document_presenter
    presenter_for(office_document.document).with_context(belongs_to: office_document)
  end

  def when_user_can_manage(&block)
    if user_can_manage?
      yield
    end
  end

  def user_can_manage?
    user_can?(:edit) || user_can?(:download) || user_can?(:destroy)
  end

  def name
    ApplicationController
      .helpers
      .document_type_display_name(office_document.document_type)
  end

  def expiration
    if office_document.expirable? && office_document.expired?
      content_tag(:span, class: "text-danger") do
        "expired on #{expires_on}"
      end
    elsif office_document.expirable?
      "expires on #{expires_on}"
    else
      'no expiration'
    end
  end

  def expires_on
    if office_document.expirable?
      I18n.localize(office_document.expires_on.to_date, format: :default)
    else
      ''
    end
  end

  def created_at
    I18n.localize(office_document.created_at.to_date, format: :default)
  end

  def edit_path
    edit_office_document_path(office_document)
  end

  def download_path
    download_office_document_path(office_document.id)
  end

  def show_office_path
    office_path(office_document.office)
  end

  def destroy_path
    office_document_path(office_document)
  end
end
