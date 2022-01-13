class CreateIncompleteAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :incomplete_assignments do |t|
      t.timestamps

      t.references :assignment, type: :uuid, index: true, foreign_key: true
      t.string :status
    end
  end
end
