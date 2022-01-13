class AddChatTermsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :chat_terms, :jsonb
  end
end
