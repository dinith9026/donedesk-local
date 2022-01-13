class CreatePlans < ActiveRecord::Migration[5.0]
  def change
    create_table :plans, id: :uuid do |t|
      t.timestamps

      t.belongs_to :account, foreign_key: true, type: :uuid, index: { unique: true }
      t.string :stripe_plan_id
      t.integer :monthly_price, null: false
      t.integer :max_employees, null: false
    end
  end
end
