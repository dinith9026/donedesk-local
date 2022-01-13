class MakeDocumentTypeNameUniquePerAccount < ActiveRecord::Migration[5.0]
  def change
    add_index :document_types, [:name, :account_id], unique: true
  end
end
