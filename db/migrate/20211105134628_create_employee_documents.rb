class CreateEmployeeDocuments < ActiveRecord::Migration[5.2]
  def up
    enable_extension 'pgcrypto'

    create_table :employee_documents, id: :uuid do |t|
      t.timestamps

      t.references :employee_record, type: :uuid, foreign_key: true, null: false, index: true
      t.references :document, type: :uuid, foreign_key: true, null: false, index: true
    end

    execute "INSERT INTO employee_documents (employee_record_id, document_id, created_at, updated_at) SELECT employee_record_id, id, created_at, updated_at FROM documents"
  end

  def down
    drop_table :employee_documents
  end
end
