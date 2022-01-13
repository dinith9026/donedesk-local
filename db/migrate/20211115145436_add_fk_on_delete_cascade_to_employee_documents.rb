class AddFkOnDeleteCascadeToEmployeeDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :employee_documents, :employee_records
    add_foreign_key :employee_documents, :employee_records, on_delete: :cascade

    remove_foreign_key :employee_documents, :documents
    add_foreign_key :employee_documents, :documents, on_delete: :cascade
  end
end
