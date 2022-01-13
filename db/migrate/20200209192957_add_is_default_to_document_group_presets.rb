class AddIsDefaultToDocumentGroupPresets < ActiveRecord::Migration[5.0]
  def change
    add_column :document_group_presets, :is_default, :boolean, null: false, default: false
    execute "UPDATE document_group_presets SET is_default = true WHERE name = 'Default'"
  end
end
