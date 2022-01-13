class RenameEmployeesToEmployeeRecords < ActiveRecord::Migration[5.0]
  def change
    rename_table :employees, :employee_records
  end
end
