class AddDashboardStatsFieldsToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :is_calculating_dashboard_stats, :boolean, null: false, default: false
    add_column :accounts, :dashboard_stats_last_updated_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
