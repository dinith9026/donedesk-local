class RemoveRequiredFromDocumentTypes < ActiveRecord::Migration[5.0]
  def up
    remove_column :document_types, :required
  end

  def down
    add_column :document_types, :required, :boolean, nil: false
  end
end
