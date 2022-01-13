class RemoveEmploymentTypesValueFromDocumentTypes < ActiveRecord::Migration[5.0]
  def up
    remove_column :document_types, :employment_types_value
  end

  def down
    add_column :document_types, :employment_types_value, :integer, default: 0
  end
end
