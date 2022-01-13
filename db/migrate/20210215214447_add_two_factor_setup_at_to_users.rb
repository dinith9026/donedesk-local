class AddTwoFactorSetupAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :two_factor_setup_at, :datetime
  end
end
