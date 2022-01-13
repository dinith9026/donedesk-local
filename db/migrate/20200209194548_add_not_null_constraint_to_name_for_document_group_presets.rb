class AddNotNullConstraintToNameForDocumentGroupPresets < ActiveRecord::Migration[5.0]
  def change
    change_column_null :document_group_presets, :name, false
  end
end
