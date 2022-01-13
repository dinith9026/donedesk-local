class CreateExams < ActiveRecord::Migration[5.0]
  def change
    create_table :exams, id: :uuid do |t|
      t.timestamps

      t.references :assignment, foreign_key: true, type: :uuid, null: true
      t.boolean :passed, null: false
    end
  end
end
