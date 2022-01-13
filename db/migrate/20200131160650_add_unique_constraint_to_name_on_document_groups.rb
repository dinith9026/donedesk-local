class AddUniqueConstraintToNameOnDocumentGroups < ActiveRecord::Migration[5.0]
  def change
    add_index :document_groups, [:title, :account_id], unique: true
  end
end
