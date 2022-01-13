class AddOwnerRefToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_reference :accounts, :owner, references: :users, type: :uuid, index: true
    add_foreign_key :accounts, :users, column: :owner_id
  end
end
