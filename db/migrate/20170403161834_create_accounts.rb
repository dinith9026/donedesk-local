class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts, id: :uuid do |t|
      t.timestamps

      t.string :name, null: false
      t.integer :monthly_price, null: false
      t.integer :per_employee_price, null: false

      t.index :name, unique: true
    end
  end
end
