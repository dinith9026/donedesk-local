class CreateAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :assignments, id: :uuid do |t|
      t.timestamps

      t.references :course, foreign_key: true, type: :uuid, null: false
      t.references :employee, foreign_key: true, type: :uuid, null: false
    end
  end
end
