class AddFkCascadeDeleteOnDocumentTypeIdForDocumentTypesGroupings < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :document_types_groupings, :document_types
    add_foreign_key :document_types_groupings, :document_types, on_delete: :cascade
  end
end
