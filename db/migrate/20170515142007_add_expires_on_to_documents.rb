class AddExpiresOnToDocuments < ActiveRecord::Migration[5.0]
  def change
    add_column :documents, :expires_on, :datetime
  end
end
