class CreateTask < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks, id: :uuid do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.date :due_date, null: false
      t.date :expiry_date, null: false
      t.date :submitted_date, null: true
      t.text :submit_note, null: true
      t.string :status, null: false
      t.integer :created_user, null: false
      t.integer :assigned_user, null: false
      t.references :account, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
