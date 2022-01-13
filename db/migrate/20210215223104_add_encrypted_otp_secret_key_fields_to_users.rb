class AddEncryptedOtpSecretKeyFieldsToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :encrypted_otp_secret_key, :string
    add_column :users, :encrypted_otp_secret_key_iv, :string
    remove_column :users, :otp_secret_key
  end

  def down
    remove_column :users, :encrypted_otp_secret_key
    remove_column :users, :encrypted_otp_secret_key_iv
    add_column :users, :otp_secret_key, :string
  end
end
