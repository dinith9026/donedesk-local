class AddDaysDueWithinToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :days_due_within, :integer
  end
end
