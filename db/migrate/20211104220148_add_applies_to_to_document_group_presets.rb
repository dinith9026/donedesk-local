class AddAppliesToToDocumentGroupPresets < ActiveRecord::Migration[5.2]
  def change
    add_column :document_group_presets, :applies_to, :string, null: false, default: 'employees'
  end
end
