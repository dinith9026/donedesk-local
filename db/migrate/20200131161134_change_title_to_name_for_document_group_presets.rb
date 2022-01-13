class ChangeTitleToNameForDocumentGroupPresets < ActiveRecord::Migration[5.0]
  def change
    rename_column :document_group_presets, :title, :name
  end
end
