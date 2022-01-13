class AddAgdMemberNumberToEmployeeRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :employee_records, :agd_member_number, :string
  end
end
