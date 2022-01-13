class RemoveUnencryptedFieldsFromEmployees < ActiveRecord::Migration[5.0]
  def up
    remove_column :employees, :dob
    remove_column :employees, :phone
    remove_column :employees, :emergency_contact_name
    remove_column :employees, :emergency_contact_relationship
    remove_column :employees, :emergency_contact_phone
    remove_column :employees, :emergency_contact_email
    remove_column :employees, :ssn
  end

  def down
    add_column :employees, :dob, :date
    add_column :employees, :phone, :string
    add_column :employees, :emergency_contact_name, :string
    add_column :employees, :emergency_contact_relationship, :string
    add_column :employees, :emergency_contact_phone, :string
    add_column :employees, :emergency_contact_email, :string
    add_column :employees, :ssn, :integer
  end
end
