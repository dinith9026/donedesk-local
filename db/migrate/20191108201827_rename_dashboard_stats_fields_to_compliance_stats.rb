class RenameDashboardStatsFieldsToComplianceStats < ActiveRecord::Migration[5.0]
  def change
    rename_column :accounts, :dashboard_stats_last_updated_at, :compliance_stats_last_updated_at
    rename_column :accounts, :is_calculating_dashboard_stats, :is_calculating_compliance_stats
  end
end
