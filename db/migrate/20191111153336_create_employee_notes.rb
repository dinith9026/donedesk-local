class CreateEmployeeNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :employee_notes do |t|
      t.timestamps

      t.references :employee_record, type: :uuid, foreign_key: { on_delete: :cascade }, null: false, index: true
      t.references :creator, references: :users, type: :uuid, foreign_key: { to_table: :users}, null: false, index: true
      t.string :body, null: false
    end
  end
end
