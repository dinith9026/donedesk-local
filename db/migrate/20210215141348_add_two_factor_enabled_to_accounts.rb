class AddTwoFactorEnabledToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :two_factor_enabled, :boolean, default: false, null: false
  end
end
