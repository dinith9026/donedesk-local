class RemovePerEmployeePriceFromAccounts < ActiveRecord::Migration[5.0]
  def change
    remove_column :accounts, :per_employee_price
  end
end
