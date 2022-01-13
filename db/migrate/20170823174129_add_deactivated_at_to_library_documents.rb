class AddDeactivatedAtToLibraryDocuments < ActiveRecord::Migration[5.0]
  def change
    add_column :library_documents, :deactivated_at, :datetime
  end
end
