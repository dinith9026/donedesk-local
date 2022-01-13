class RemoveDocumentFromDocuments < ActiveRecord::Migration[5.0]
  def change
    remove_attachment :documents, :document
  end
end
