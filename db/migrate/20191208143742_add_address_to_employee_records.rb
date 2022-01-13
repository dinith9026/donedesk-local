class AddAddressToEmployeeRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_records, :encrypted_address, :string
    add_column :employee_records, :encrypted_address_iv, :string
  end
end
