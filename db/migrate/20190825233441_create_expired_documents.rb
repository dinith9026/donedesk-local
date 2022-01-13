class CreateExpiredDocuments < ActiveRecord::Migration[5.0]
  def change
    create_table :expired_documents do |t|
      t.timestamps

      t.references :employee_record, type: :uuid, index: true, foreign_key: true
      t.references :document_type, type: :uuid, index: true, foreign_key: true
    end
  end
end
