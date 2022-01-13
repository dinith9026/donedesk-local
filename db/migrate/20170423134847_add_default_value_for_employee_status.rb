class AddDefaultValueForEmployeeStatus < ActiveRecord::Migration[5.0]
  def change
    change_column_default :employees, :status, 1
  end
end
