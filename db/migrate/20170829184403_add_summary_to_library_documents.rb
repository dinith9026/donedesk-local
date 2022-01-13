class AddSummaryToLibraryDocuments < ActiveRecord::Migration[5.0]
  def change
    add_column :library_documents, :summary, :string
  end
end
