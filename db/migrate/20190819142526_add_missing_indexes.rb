class AddMissingIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :assignments, [:course_id, :employee_record_id]
  end
end
