class AddHiredOnToEmployeeRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_records, :hired_on, :datetime
  end
end
