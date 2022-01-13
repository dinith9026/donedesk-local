class DeprecateEmployeeRecordIdOnDocuments < ActiveRecord::Migration[5.2]
  def change
    rename_column :documents, :employee_record_id, :deprecated_employee_record_id
  end
end
