class AddEncryptedFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :encrypted_dob, :string
    add_column :employees, :encrypted_phone, :string
    add_column :employees, :encrypted_emergency_contact_name, :string
    add_column :employees, :encrypted_emergency_contact_relationship, :string
    add_column :employees, :encrypted_emergency_contact_phone, :string
    add_column :employees, :encrypted_emergency_contact_email, :string
    add_column :employees, :encrypted_ssn, :string

    add_column :employees, :encrypted_dob_iv, :string
    add_column :employees, :encrypted_phone_iv, :string
    add_column :employees, :encrypted_emergency_contact_name_iv, :string
    add_column :employees, :encrypted_emergency_contact_relationship_iv, :string
    add_column :employees, :encrypted_emergency_contact_phone_iv, :string
    add_column :employees, :encrypted_emergency_contact_email_iv, :string
    add_column :employees, :encrypted_ssn_iv, :string
  end
end
