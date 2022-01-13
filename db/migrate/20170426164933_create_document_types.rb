class CreateDocumentTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :document_types, id: :uuid do |t|
      t.timestamps

      t.string :name, index: true, unique: true
      t.boolean :required, nil: false
    end
  end
end
