class AddDeactivatedAtToTracks < ActiveRecord::Migration[5.0]
  def change
    add_column :tracks, :deactivated_at, :datetime
  end
end
