class OfficeDocumentsController < ApplicationController
  def index
    office = current_account.offices.find(params[:office_id])
    office_documents = office.documents_for(params[:document_type_id])
    authorize office_documents.first, :view_history?

    @office_documents_presenter = OfficeDocumentsPresenter.new(office_documents, current_user)

    respond_to do |format|
      format.js
    end
  rescue ActiveRecord::RecordNotFound
    skip_authorization
    head 404
  end

  def new
    @office = current_account.offices.find(params[:office_id])
    authorize @office, :new_document?
    @document_form =
      DocumentForm
      .new
      .with_context(user: current_user, document_types: get_filtered_document_types(@office))
  end

  def create
    @office = current_account.offices.find(params[:office_id])
    authorize @office, :create_document?

    @document_form =
      DocumentForm
      .from_params(document_params)
      .with_context(user: current_user, document_types: get_filtered_document_types(@office))

    if @document_form.valid?
      ActiveRecord::Base.transaction do
        document = Document.create!(document_params)
        OfficeDocument.create!(office: @office, document: document)
      end

      set_flash_success_and_redirect_to(@office)
    else
      set_flash_error_and_render(:new)
    end
  end

  def edit
    @office_document = current_account.office_documents.includes(:office, :document).find(params[:id])
    authorize @office_document

    @document_form =
      DocumentForm
      .from_model(@office_document.document)
      .with_context(user: current_user, document_types: get_filtered_document_types(@office_document.office), new_document_path: new_office_document_path(@office_document.office))
  end

  def update
    @office_document = current_account.office_documents.includes(:office, :document).find(params[:id])
    authorize @office_document

    @document_form =
      DocumentForm
      .from_model(@office_document.document)
      .with_context(user: current_user, document_types: get_filtered_document_types(@office_document.office), new_document_path: new_office_document_path(@office_document.office))

    @document_form.attributes = document_params.to_h
    authorize @office_document

    UpdateDocument.call(@document_form, @office_document.document) do
      on(:ok)      { set_flash_success_and_redirect_to(smart_back_path) }
      on(:invalid) { set_flash_error_and_render(:edit) }
    end
  end

  def download
    office_document = current_account.office_documents.find(params[:id])
    authorize office_document

    document = office_document.document

    data = open(document.file_expiring_url(60))
    send_data(data.read,
              filename: document.file_file_name,
              type: document.file_content_type,
              disposition: document.download_disposition)
  end

  def destroy
    office_document = current_account.office_documents.find(params[:id])
    authorize office_document

    office_document.document.destroy!

    set_flash_success_and_redirect_to(smart_back_path)
  end

  private

  def document_params
    params.require(:document).permit(:document_type_id, :file, :expires_on, :summary)
  end

  def get_filtered_document_types(office)
    document_types_list.select do |document_type|
      document = Document.new(document_type: document_type)
      office_document = office.build_document(document)
      policy(office_document).create?
    end
  end

  def document_types_list
    DocumentType
      .where(account_id: nil)
      .or(DocumentType.where(account_id: current_account.id))
      .where(applies_to: 'offices')
      .order(:name)
  end
end
