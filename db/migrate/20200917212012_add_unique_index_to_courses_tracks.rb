class AddUniqueIndexToCoursesTracks < ActiveRecord::Migration[5.0]
  def change
    add_index :courses_tracks, [:track_id, :course_id], unique: true
  end
end
