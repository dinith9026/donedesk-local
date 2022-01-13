class AddUniqueConstraintToPTOEntries < ActiveRecord::Migration[5.0]
  def change
    add_index :pto_entries, [:employee_record_id, :date], unique: true
  end
end
