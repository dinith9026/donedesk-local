class ChangeTitleToNameForDocumentGroups < ActiveRecord::Migration[5.0]
  def change
    rename_column :document_groups, :title, :name
  end
end
