class AddPositionToCoursesTracks < ActiveRecord::Migration[5.0]
  def change
    add_column :courses_tracks, :position, :integer
  end
end
