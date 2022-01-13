class CreateTaskDocument < ActiveRecord::Migration[5.2]
  def change
    create_table :task_documents, id: :uuid do |t|
      t.string :file_name, null: true
      t.string :file_path, null: true
      t.references :task, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
