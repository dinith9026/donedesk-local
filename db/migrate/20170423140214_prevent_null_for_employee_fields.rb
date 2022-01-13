class PreventNullForEmployeeFields < ActiveRecord::Migration[5.0]
  def change
    change_column_null :employees, :title, false
    change_column_null :employees, :dob, false
    change_column_null :employees, :phone, false
    change_column_null :employees, :emergency_contact_name, false
    change_column_null :employees, :emergency_contact_phone, false
    change_column_null :employees, :emergency_contact_email, false
    change_column_null :employees, :emergency_contact_relationship, false
    change_column_null :employees, :status, false
    change_column_null :employees, :ssn, false
    change_column_null :employees, :gender, false
    change_column_null :employees, :marital_status, false
  end
end
