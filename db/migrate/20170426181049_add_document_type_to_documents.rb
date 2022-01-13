class AddDocumentTypeToDocuments < ActiveRecord::Migration[5.0]
  def change
    remove_column :documents, :name
    add_reference :documents, :document_type, type: :uuid, index: true, foreign_key: true, null: false
  end
end
