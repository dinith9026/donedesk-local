class AddLastSignInFieldsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :sign_in_count, :integer, null: false, default: 0
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :last_sign_in_ip, :inet
  end
end
