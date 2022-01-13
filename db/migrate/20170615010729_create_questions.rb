class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions, id: :uuid do |t|
      t.timestamps

      t.references :course, foreign_key: true, type: :uuid, null: false
      t.string :sentence, null: false
    end
  end
end
