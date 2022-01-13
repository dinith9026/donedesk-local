class CreateChoices < ActiveRecord::Migration[5.0]
  def change
    create_table :choices, id: :uuid do |t|
      t.timestamps

      t.references :question, foreign_key: true, type: :uuid, null: false
      t.string :answer, null: false
      t.boolean :is_correct, null: false, default: false
    end
  end
end
