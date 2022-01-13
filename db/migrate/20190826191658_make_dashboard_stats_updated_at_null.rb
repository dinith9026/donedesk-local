class MakeDashboardStatsUpdatedAtNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :accounts, :dashboard_stats_last_updated_at, true, Time.now
  end
end
