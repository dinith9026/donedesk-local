class AddUniqueConstraintForCourseTitle < ActiveRecord::Migration[5.0]
  def change
    add_index :courses, [:title, :account_id], unique: true
  end
end
