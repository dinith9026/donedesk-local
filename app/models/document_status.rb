class DocumentStatus
  include ActiveModel::Model

  attr_reader :owned_by, :document_types_grouping, :existing_documents

  delegate :is_confidential, :document_type, to: :document_types_grouping

  def initialize(owned_by, document_types_grouping, existing_documents)
    @owned_by = owned_by
    @document_types_grouping = document_types_grouping
    @existing_documents = existing_documents
  end

  def document_type_id
    document_type.id
  end

  def document_type_name
    document_type.name
  end

  def document
    existing_documents.find do |document|
      document.document_type_id == document_type_id
    end
  end

  def required
    document_types_grouping.required
  end

  def build_document(document)
    owned_by.build_document(document)
  end
end
