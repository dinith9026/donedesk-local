class AddUniqueConstraintToTrackPresetsName < ActiveRecord::Migration[5.0]
  def change
    remove_index :track_presets, [:name]
    add_index :track_presets, [:name], unique: true
  end
end
