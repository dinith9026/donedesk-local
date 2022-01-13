class RemoveCourseIdFromExams < ActiveRecord::Migration[5.0]
  def up
    remove_reference :exams, :course
  end

  def down
    add_reference :exams, :course, index: true, foreign_key: { on_delete: :cascade }, type: :uuid
    execute "UPDATE exams SET course_id = subquery.course_id FROM (SELECT id, course_id FROM assignments) AS subquery WHERE exams.assignment_id = subquery.id"
    change_column_null :exams, :course_id, false
  end
end
