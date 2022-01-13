class RemoveTrackIdFromAssignments < ActiveRecord::Migration[5.0]
  def up
    remove_index :assignments, [:track_id, :employee_record_id]
    remove_index :assignments, name: 'index_assignments_on_employee_record_id_and_track_id'

    remove_index :assignments, name: 'index_assignments_on_employee_record_id_and_course_id'
    add_index :assignments, [:employee_record_id, :course_id], unique: true

    remove_column :assignments, :track_id
  end

  def down
    add_reference :assignments, :track, type: :uuid, foreign_key: { on_delete: :cascade}, index: true

    add_index :assignments, [:track_id, :employee_record_id]
    add_index :assignments, [:employee_record_id, :track_id], unique: true, where: 'track_id IS NOT NULL'
    remove_index :assignments, name: 'index_assignments_on_employee_record_id_and_course_id'
    add_index :assignments, [:employee_record_id, :course_id], unique: true, where: 'course_id IS NOT NULL'
  end
end
