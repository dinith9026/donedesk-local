class CreateTrackPresets < ActiveRecord::Migration[5.0]
  def change
    create_table :track_presets, id: :uuid do |t|
      t.timestamps

      t.citext :name, index: true
      t.jsonb :courses, null: false, default: []
    end
  end
end
