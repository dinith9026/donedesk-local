class ChangeUniqueConstraintForDocumentTypesName < ActiveRecord::Migration[5.2]
  def up
    remove_index :document_types, [:name, :account_id]
    add_index :document_types, [:name, :account_id, :applies_to], unique: true
  end

  def down
    remove_index :document_types, [:name, :account_id, :applies_to]
    add_index :document_types, [:name, :account_id], unique: true
  end
end
