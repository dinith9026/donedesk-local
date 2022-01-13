class DropEmployeeRecordsTracks < ActiveRecord::Migration[5.0]
  def up
    drop_table :employee_records_tracks
  end

  def down
    create_table :employee_records_tracks, id: :uuid do |t|
      t.timestamps

      t.references :track, type: :uuid, index: true, foreign_key: {on_delete: :cascade}, null: false
      t.references :employee_record, type: :uuid, index: true, foreign_key: {on_delete: :cascade}, null: false
    end
  end
end
