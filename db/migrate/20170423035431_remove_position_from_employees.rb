class RemovePositionFromEmployees < ActiveRecord::Migration[5.0]
  def change
    remove_column :employees, :position
  end
end
