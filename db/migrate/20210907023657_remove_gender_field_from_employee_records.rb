class RemoveGenderFieldFromEmployeeRecords < ActiveRecord::Migration[5.2]
  def change
    remove_column :employee_records, :gender
  end

  def down
    add_column :employee_records, :gender, :integer
  end
end
