class AddIsConfidentialToDocumentTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :document_types, :is_confidential, :boolean, null: false, default: false
  end
end
