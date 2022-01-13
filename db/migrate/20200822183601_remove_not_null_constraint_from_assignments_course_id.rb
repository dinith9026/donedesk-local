class RemoveNotNullConstraintFromAssignmentsCourseId < ActiveRecord::Migration[5.0]
  def up
    change_column_null :assignments, :course_id, true
  end

  def down
    change_column_null :assignments, :course_id, false
  end
end
