class DocumentTypesGrouping < ApplicationRecord
  belongs_to :document_group
  belongs_to :document_type

  delegate :id, :name, to: :document_type, prefix: true
  delegate :is_confidential, to: :document_type
end
