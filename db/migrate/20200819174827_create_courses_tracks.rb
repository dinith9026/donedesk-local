class CreateCoursesTracks < ActiveRecord::Migration[5.0]
  def change
    create_table :courses_tracks, id: :uuid do |t|
      t.timestamps

      t.references :track, type: :uuid, index: true, foreign_key: {on_delete: :cascade}, null: false
      t.references :course, type: :uuid, index: true, foreign_key: {on_delete: :cascade}, null: false
    end
  end
end
