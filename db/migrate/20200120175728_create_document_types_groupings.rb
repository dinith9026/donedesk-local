class CreateDocumentTypesGroupings < ActiveRecord::Migration[5.0]
  def change
    create_table :document_types_groupings, id: :uuid do |t|
      t.timestamps

      t.references :document_type, type: :uuid, index: true, foreign_key: true, null: false
      t.references :document_group, type: :uuid, index: true, foreign_key: true, null: false
      t.boolean :required, default: false
    end
  end
end
