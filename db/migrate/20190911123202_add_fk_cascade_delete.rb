class AddFkCascadeDelete < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :incomplete_assignments, :assignments
    add_foreign_key :incomplete_assignments, :assignments, on_delete: :cascade

    remove_foreign_key :expiring_documents, :employee_records
    remove_foreign_key :expiring_documents, :document_types
    add_foreign_key :expiring_documents, :employee_records, on_delete: :cascade
    add_foreign_key :expiring_documents, :document_types, on_delete: :cascade

    remove_foreign_key :expired_documents, :employee_records
    remove_foreign_key :expired_documents, :document_types
    add_foreign_key :expired_documents, :employee_records, on_delete: :cascade
    add_foreign_key :expired_documents, :document_types, on_delete: :cascade

    remove_foreign_key :missing_documents, :employee_records
    remove_foreign_key :missing_documents, :document_types
    add_foreign_key :missing_documents, :employee_records, on_delete: :cascade
    add_foreign_key :missing_documents, :document_types, on_delete: :cascade
  end
end
