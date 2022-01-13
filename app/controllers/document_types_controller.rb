class DocumentTypesController < ApplicationController
  def index
    authorize DocumentType
    document_types = ListDocumentTypesForAccount.new(current_account).query.includes(:documents)

    @document_types_presenter =
      DocumentTypesPresenter.new(document_types, current_user, policy(DocumentType))
  end

  def new
    authorize DocumentType
    @form = DocumentTypeForm.new.with_policy(policy(DocumentType))
  end

  def create
    @form = DocumentTypeForm.from_params(document_type_params, account_id: current_account.id)
                            .with_policy(policy(DocumentType))
    authorize @form

    CreateDocumentType.call(@form, current_account) do
      on(:ok) do |document_type|
        respond_to do |format|
          format.js { render :create, locals: { document_type: document_type } }
          format.html { set_flash_success_and_redirect_to(document_types_url) }
        end
      end
      on(:invalid) do |form|
        respond_to do |format|
          format.js { render :create, locals: { errors: form.errors.full_messages } }
          format.html { render :new }
        end
      end
    end
  end

  def edit
    document_type = find_document_type
    @form = DocumentTypeForm.from_model(document_type)
                            .with_policy(policy(document_type))
    authorize @form
  end

  def update
    document_type = find_document_type
    @form = DocumentTypeForm.from_model(document_type)
                            .with_policy(policy(document_type))
    @form.attributes = document_type_params.to_h
    authorize @form

    UpdateDocumentType.call(@form, document_type, current_account) do
      on(:ok) do
        flash[:success] = 'Document type updated!'
        redirect_to document_types_url
      end
      on(:invalid) do
        render :edit
      end
    end
  end

  def destroy
    document_type = find_document_type
    authorize document_type

    document_type.destroy!

    set_flash_success_and_redirect_to(document_types_url)
  end

  private

  def find_document_type
    @document_type ||= FindDocumentTypeForAccount.new(current_account, params[:id]).query
  end

  def document_type_params
    params.require(:document_type)
          .permit(policy(DocumentType.new).permitted_attributes)
  end
end
