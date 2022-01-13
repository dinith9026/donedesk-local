class CreateAccountComplianceStats < ActiveRecord::Migration[5.0]
  def change
    create_table :account_compliance_stats, id: :uuid do |t|
      t.timestamps

      t.references :account, type: :uuid, foreign_key: true, null: false, index: { unique: true }
      t.integer :document_compliance_percentage, null: false
      t.integer :training_compliance_percentage, null: false
    end
  end
end
