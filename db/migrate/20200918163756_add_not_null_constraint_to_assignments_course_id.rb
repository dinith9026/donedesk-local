class AddNotNullConstraintToAssignmentsCourseId < ActiveRecord::Migration[5.0]
  def up
    execute "DELETE FROM assignments WHERE course_id IS NULL"
    change_column_null :assignments, :course_id, false
  end

  def down
    change_column_null :assignments, :course_id, true
  end
end
