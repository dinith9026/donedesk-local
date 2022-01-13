class AddNotNullConstraintToNameForDocumentGroups < ActiveRecord::Migration[5.0]
  def change
    change_column_null :document_groups, :name, false
  end
end
