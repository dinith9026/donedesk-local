class RemoveAccountIdFromContactTable < ActiveRecord::Migration[5.2]
  def change
    remove_column :contacts, :account_id
  end
end
