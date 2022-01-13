class AddUniquenessConstraintToAssignments < ActiveRecord::Migration[5.0]
  def change
    add_index :assignments, [:employee_id, :course_id], unique: true
  end
end
