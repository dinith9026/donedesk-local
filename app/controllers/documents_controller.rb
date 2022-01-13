class DocumentsController < ApplicationController
  def index
    authorize Document

    if params[:type] == 'employees'
      documents = current_account.employee_documents
    elsif params[:type] == 'offices'
      documents = current_account.office_documents
    else
      documents = current_account.employee_documents
    end

    if params[:search].present?
      documents = documents.search(params[:search])
    end

    documents =
      documents
      .page(params[:page])
      .per(10)

    @documents_presenter = DocumentsPresenter.new(documents, current_user, policy(Document.new))
  end
end
