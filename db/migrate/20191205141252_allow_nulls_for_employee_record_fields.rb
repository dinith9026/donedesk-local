class AllowNullsForEmployeeRecordFields < ActiveRecord::Migration[5.0]
  def change
    change_column_null :employee_records, :title, true
    change_column_null :employee_records, :gender, true
    change_column_null :employee_records, :marital_status, true

    change_column_null :employee_records, :office_id, false
    change_column_null :employee_records, :employment_type, false
  end
end
