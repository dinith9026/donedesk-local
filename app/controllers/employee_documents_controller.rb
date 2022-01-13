class EmployeeDocumentsController < ApplicationController
  def index
    employee_record = current_account.employee_records.find(employee_record_id)
    employee_documents = employee_record.documents_for(document_type_id)
    authorize employee_documents.first, :view_history?

    @employee_documents_presenter = EmployeeDocumentsPresenter.new(employee_documents, current_user)

    respond_to do |format|
      format.js
    end
  rescue ActiveRecord::RecordNotFound
    skip_authorization
    head 404
  end

  def new
    @employee = find_employee_record
    document_type = params[:document_type_id].present? ? find_document_type(params[:document_type_id]) : nil

    if document_type.present?
      authorize EmployeeDocument.new(employee_record: @employee, document: Document.new(document_type: document_type))
    else
      authorize @employee, :new_document?
    end
    @document_form = DocumentForm.new.with_context(user: current_user, document_types: get_filtered_document_types(@employee))
  end

  def create
    @employee = find_employee_record
    document = Document.new(document_params)
    @document_form = DocumentForm
                      .from_model(document)
                      .with_context(user: current_user, document_types: get_filtered_document_types(@employee))
    authorize EmployeeDocument.new(employee_record: @employee, document: document)

    CreateDocument.call(@document_form, @employee) do
      on(:ok)      { |employee_record_id| set_flash_success_and_redirect_to(employee_record_path(employee_record_id)) }
      on(:invalid) { set_flash_error_and_render(:new) }
    end
  end

  def edit
    @employee_document = current_account.employee_documents.find(params[:id])
    @employee = @employee_document.employee_record
    @document_form =
      DocumentForm
      .from_model(@employee_document.document)
      .with_context(user: current_user, document_types: get_filtered_document_types(@employee), new_document_path: new_employee_record_document_path(@employee))
    authorize @employee_document
  end

  def update
    @employee_document = current_account.employee_documents.find(params[:id])
    @employee = @employee_document.employee_record
    @document_form =
      DocumentForm
      .from_model(@employee_document.document)
      .with_context(user: current_user, document_types: get_filtered_document_types(@employee), new_document_path: new_employee_record_document_path(@employee))
    @document_form.attributes = document_params.to_h
    authorize @employee_document

    UpdateDocument.call(@document_form, @employee_document.document) do
      on(:ok)      { set_flash_success_and_redirect_to(documents_url) }
      on(:invalid) { set_flash_error_and_render(:edit) }
    end
  end

  def download
    employee_document = current_account.employee_documents.find(params[:id])
    authorize employee_document

    document = employee_document.document

    data = open(document.file_expiring_url(60))
    send_data(data.read,
              filename: document.file_file_name,
              type: document.file_content_type,
              disposition: document.download_disposition)
  end

  def destroy
    employee_document = current_account.employee_documents.find(params[:id])
    authorize employee_document

    employee_document.document.destroy!

    set_flash_success_and_redirect_to(smart_back_path)
  end

  private

  def document_params
    params
      .require(:document)
      .permit(:document_type_id, :file, :expires_on, :summary)
  end

  def find_employee_record
    current_account.employee_records.find(employee_record_id)
  end

  def find_document_type(document_type_id)
    document_types_list.find { |document_type| document_type.id == document_type_id }
  end

  def get_filtered_document_types(employee_record)
    document_types_list.select do |document_type|
      document = Document.new(document_type: document_type)
      employee_document = employee_record.build_document(document)
      policy(employee_document).create?
    end
  end

  def document_types_list
    DocumentType
      .where(account_id: nil)
      .or(DocumentType.where(account_id: current_account.id))
      .where(applies_to: 'employees')
      .order(:name)
  end

  def employee_record_id
    params[:employee_record_id]
  end

  def document_type_id
    params[:document_type_id]
  end
end
