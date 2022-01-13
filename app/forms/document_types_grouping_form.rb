class DocumentTypesGroupingForm < ApplicationForm
  attribute :document_type_id, String
  attribute :required, Boolean, default: false
end
