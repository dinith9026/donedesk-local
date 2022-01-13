class AddFkOnDeleteCascadeToOfficeDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :office_documents, :offices
    add_foreign_key :office_documents, :offices, on_delete: :cascade

    remove_foreign_key :office_documents, :documents
    add_foreign_key :office_documents, :documents, on_delete: :cascade
  end
end
