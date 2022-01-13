class AddUniqueConstraintForUserIdOnEmployeeRecords < ActiveRecord::Migration[5.0]
  def change
    remove_index :employee_records, :user_id
    add_index :employee_records, :user_id, unique: true
  end
end
