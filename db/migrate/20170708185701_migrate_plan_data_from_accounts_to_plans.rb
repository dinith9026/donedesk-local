class MigratePlanDataFromAccountsToPlans < ActiveRecord::Migration[5.0]
  def up
    execute <<~HEREDOC
    INSERT INTO plans (account_id, stripe_plan_id, monthly_price, max_employees, created_at, updated_at)
      SELECT id, stripe_plan_id, monthly_price, max_employees, NOW(), NOW()
      FROM   accounts
    HEREDOC
  end

  def down
    execute "DELETE FROM plans"
  end
end
