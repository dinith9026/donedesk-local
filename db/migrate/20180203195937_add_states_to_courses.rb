class AddStatesToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :states, :string, array: true, default: []
  end
end
