class AddAttachmentFileToLibraryDocuments < ActiveRecord::Migration[5.0]
  def self.up
    change_table :library_documents do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :library_documents, :file
  end
end
