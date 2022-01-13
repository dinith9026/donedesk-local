class RemoveOwnerIdFromAccount < ActiveRecord::Migration[5.0]
  def change
    remove_column :accounts, :owner_id
  end
end
