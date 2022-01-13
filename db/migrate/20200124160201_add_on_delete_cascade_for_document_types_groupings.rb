class AddOnDeleteCascadeForDocumentTypesGroupings < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :document_types_groupings, :document_groups
    add_foreign_key :document_types_groupings, :document_groups, on_delete: :cascade
  end
end
