class AddInviteTokenToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :invite_token, :string, limit: 128, index: true
  end
end
