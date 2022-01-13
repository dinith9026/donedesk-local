class AddDeactivatedAtToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :deactivated_at, :datetime
  end
end
