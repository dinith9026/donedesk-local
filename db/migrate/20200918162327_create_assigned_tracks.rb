class CreateAssignedTracks < ActiveRecord::Migration[5.0]
  def change
    create_table :assigned_tracks, id: :uuid do |t|
      t.timestamps

      t.references :track, foreign_key: { on_delete: :cascade }, type: :uuid, null: false
      t.references :employee_record, foreign_key: { on_delete: :cascade }, type: :uuid, null: false
    end

    add_index :assigned_tracks, [:track_id, :employee_record_id]
    add_index :assigned_tracks, [:employee_record_id, :track_id], unique: true
  end
end
