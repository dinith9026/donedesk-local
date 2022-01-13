class CreateLibraryDocuments < ActiveRecord::Migration[5.0]
  def change
    create_table :library_documents, id: :uuid do |t|
      t.timestamps

      t.references :account, type: :uuid, index: true, foreign_key: true
      t.string :name, null: false
    end

    add_index :library_documents, [:name, :account_id], unique: true
  end
end
