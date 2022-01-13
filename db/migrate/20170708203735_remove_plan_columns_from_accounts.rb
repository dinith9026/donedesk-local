class RemovePlanColumnsFromAccounts < ActiveRecord::Migration[5.0]
  def up
    remove_column :accounts, :monthly_price
    remove_column :accounts, :max_employees
    remove_column :accounts, :stripe_plan_id
  end

  def down
    add_column :accounts, :monthly_price, :integer, null: false
    add_column :accounts, :max_employees, :integer, null: false
    add_column :accounts, :stripe_plan_id, :string
  end
end
