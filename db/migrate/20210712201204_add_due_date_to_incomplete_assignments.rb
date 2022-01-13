class AddDueDateToIncompleteAssignments < ActiveRecord::Migration[5.2]
  def change
    add_column :incomplete_assignments, :due_date, :date, null: true
  end
end
