class DocumentTypePresenter < ModelPresenter
  presents :document_type
  delegate :id, :name, :applies_to, :is_confidential, to: :document_type

  def edit_path
    edit_document_type_path(document_type)
  end
end
