class AddOnDeleteForEmployeeRecordsUserId < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :employee_records, :users
    add_foreign_key :employee_records, :users, on_delete: :nullify
  end
end
