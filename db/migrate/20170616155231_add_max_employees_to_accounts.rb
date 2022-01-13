class AddMaxEmployeesToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :max_employees, :integer, null: false, default: 5
  end
end
