class RemoveSsn < ActiveRecord::Migration[5.0]
  def up
    remove_column :employee_records, :encrypted_ssn
    remove_column :employee_records, :encrypted_ssn_iv
  end

  def down
    add_column :employee_records, :encrypted_ssn, :string
    add_column :employee_records, :encrypted_ssn_iv, :string
  end
end
