class AddTerminatedAtToEmployeeRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_records, :terminated_at, :datetime
  end
end
