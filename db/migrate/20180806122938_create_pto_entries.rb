class CreatePTOEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :pto_entries, id: :uuid do |t|
      t.timestamps

      t.references :employee_record, foreign_key: true, type: :uuid, null: false
      t.decimal :hours, null: false, default: 0
      t.date :date, null: false
    end
  end
end
