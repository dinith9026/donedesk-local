class AddTimeZoneToOffices < ActiveRecord::Migration[5.0]
  def change
    add_column :offices, :time_zone, :string, null: false, default: 'Central Time (US & Canada)'
  end
end
