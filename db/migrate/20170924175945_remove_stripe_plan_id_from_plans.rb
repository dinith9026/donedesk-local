class RemoveStripePlanIdFromPlans < ActiveRecord::Migration[5.0]
  def up
    remove_column :plans, :stripe_plan_id
  end

  def down
    add_column :plans, :stripe_plan_id, :string
  end
end
