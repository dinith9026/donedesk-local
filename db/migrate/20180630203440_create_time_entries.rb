class CreateTimeEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :time_entries, id: :uuid do |t|
      t.timestamps

      t.references :employee_record, foreign_key: true, type: :uuid, null: false
      t.datetime :occurred_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }, index: true
      t.integer :entry_type, null: false, default: 0
    end
  end
end
