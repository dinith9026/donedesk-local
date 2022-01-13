class AddFkCascadeDeleteOnAccountIdForDocumentGroups < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :document_groups, :accounts
    add_foreign_key :document_groups, :accounts, on_delete: :cascade
  end
end
