class AddNameFieldsToEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :first_name, :string, null: false
    add_column :employees, :last_name, :string, null: false
  end
end
