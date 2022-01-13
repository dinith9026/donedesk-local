class CreateDocuments < ActiveRecord::Migration[5.0]
  def change
    create_table :documents, id: :uuid do |t|
      t.timestamps

      t.references :employee, type: :uuid, foreign_key: true, null: false, index: true
      t.string :name, null: false
      t.attachment :document
    end
  end
end
