class CreateExpiringDocuments < ActiveRecord::Migration[5.0]
  def change
    create_table :expiring_documents do |t|
      t.timestamps

      t.references :employee_record, type: :uuid, index: true, foreign_key: true
      t.references :document_type, type: :uuid, index: true, foreign_key: true
      t.integer :days_until_expiry, null: false
    end
  end
end
