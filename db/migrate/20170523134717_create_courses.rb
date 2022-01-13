class CreateCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :courses, id: :uuid do |t|
      t.timestamps

      t.references :account, foreign_key: true, type: :uuid, null: true
      t.string :title, null: false
    end
  end
end
