class AddAccountToDocumentTypes < ActiveRecord::Migration[5.0]
  def change
    add_reference :document_types, :account, type: :uuid, index: true, foreign_key: true
  end
end
