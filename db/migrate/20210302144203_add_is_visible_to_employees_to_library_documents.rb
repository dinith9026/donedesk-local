class AddIsVisibleToEmployeesToLibraryDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :library_documents, :is_visible_to_employees, :boolean, default: false, null: false
  end
end
