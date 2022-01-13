class LibraryDocumentsController < ApplicationController
  def index
    authorize LibraryDocument.new

    library_documents =
      ListLibraryDocumentsForAccount
      .new(current_account.id)
      .query
      .includes(:account)
      .page(params[:page])
      .per(10)

    if params[:search]
      library_documents = library_documents.where("name ILIKE ? OR summary ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    else
      if params[:type] == 'my documents'
        library_documents = library_documents.custom(current_account)
      elsif params[:type] == 'other documents'
        library_documents = library_documents.canned
      end
    end

    if current_user.employee?
      library_documents = library_documents.where(is_visible_to_employees: true)
    end

    @library_documents_presenter =
      LibraryDocumentsPresenter.new(
        library_documents,
        current_user,
        policy(LibraryDocument))
  end

  def new
    library_document = LibraryDocument.new
    authorize library_document

    @presenter = LibraryDocumentPresenter.new(library_document, policy(library_document))
    @form = LibraryDocumentForm.new.with_policy(policy(LibraryDocument.new))
  end

  def create
    library_document = LibraryDocument.new
    authorize library_document
    @presenter = LibraryDocumentPresenter.new(library_document, policy(library_document))
    @form = LibraryDocumentForm
            .from_params(library_document_params, account_id: current_account.id)
            .with_policy(policy(LibraryDocument.new))

    CreateLibraryDocument.call(@form, current_account) do
      on(:ok)      { set_flash_success_and_redirect_to(library_documents_url) }
      on(:invalid) { set_flash_error_and_render(:new) }
    end
  end

  def show
    library_document = LibraryDocument.find(params[:id])
    authorize library_document

    data = open(library_document.file_expiring_url(60))
    send_data(data.read,
              filename: library_document.file_name,
              type: library_document.file_content_type,
              disposition: 'inline')
  end

  def edit
    library_document = LibraryDocument.find(params[:id])
    authorize library_document

    @presenter = LibraryDocumentPresenter.new(library_document, policy(library_document))
    @form = LibraryDocumentForm.from_model(library_document)
                               .with_policy(policy(library_document))
  end

  def update
    library_document = LibraryDocument.find(params[:id])
    authorize library_document

    @presenter = LibraryDocumentPresenter.new(library_document, policy(library_document))
    @form = LibraryDocumentForm.from_model(library_document)
                               .with_policy(policy(library_document))
    @form.attributes = library_document_params.to_h

    UpdateLibraryDocument.call(@form, library_document, current_account) do
      on(:ok)      { set_flash_success_and_redirect_to(library_documents_url) }
      on(:invalid) { set_flash_error_and_render(:edit) }
    end
  end

  def download
    library_document = LibraryDocument.find(params[:id])
    authorize library_document

    data = open(library_document.file_expiring_url(60))
    send_data(data.read,
              filename: library_document.file_name,
              type: library_document.file_content_type,
              disposition: 'attachment')
  end

  def destroy
    library_document = LibraryDocument.find(params[:id])
    authorize library_document

    library_document.destroy!
    set_flash_success_and_redirect_to(library_documents_url)
  end

  def library_document_params
    params.require(:library_document).permit(policy(LibraryDocument).permitted_attributes)
  end
end
