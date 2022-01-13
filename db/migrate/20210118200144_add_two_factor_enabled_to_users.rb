class AddTwoFactorEnabledToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :two_factor_enabled, :boolean

    # Enable 2FA for super admins
    execute "UPDATE users SET two_factor_enabled = TRUE where role = 1;"
  end


  def down
    remove_column :users, :two_factor_enabled, :boolean
  end
end
