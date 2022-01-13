class CreateDocumentGroupPresets < ActiveRecord::Migration[5.0]
  def change
    enable_extension('citext')

    create_table :document_group_presets, id: :uuid do |t|
      t.timestamps

      t.citext :title, index: true
      t.jsonb :document_types, null: false, default: []
    end
  end
end
