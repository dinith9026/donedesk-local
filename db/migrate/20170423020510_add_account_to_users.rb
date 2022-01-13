class AddAccountToUsers < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :account, index: true, foreign_key: true, type: :uuid
  end
end
