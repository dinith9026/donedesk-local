class AddTracksTimeToOffice < ActiveRecord::Migration[5.0]
  def change
    add_column :offices, :tracks_time, :boolean, null: false, default: false
  end
end
