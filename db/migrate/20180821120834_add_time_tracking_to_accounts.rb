class AddTimeTrackingToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :time_tracking, :boolean, null: false, default: false
  end
end
