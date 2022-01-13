class AddDeactivatedAtToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :deactivated_at, :datetime
  end
end
