class ChangeDocumentTypesFieldsToPreventNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :document_types, :name, false
    change_column_null :document_types, :required, false
  end
end
