class RemoveDeactivatedAtFromLibraryDocuments < ActiveRecord::Migration[5.0]
  def up
    remove_column :library_documents, :deactivated_at
  end

  def down
    add_column :library_documents, :deactivated_at, :datetime
  end
end
