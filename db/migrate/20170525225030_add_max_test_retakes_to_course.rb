class AddMaxTestRetakesToCourse < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :max_test_retakes, :integer, null: false
  end
end
