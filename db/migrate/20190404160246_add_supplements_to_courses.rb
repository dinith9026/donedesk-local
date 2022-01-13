class AddSupplementsToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :supplements, :string, array: true, default: []
  end
end
