class AddOfficeDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :office_documents, id: :uuid do |t|
      t.timestamps

      t.references :office, type: :uuid, foreign_key: true, null: false, index: true
      t.references :document, type: :uuid, foreign_key: true, null: false, index: true
    end
  end
end
