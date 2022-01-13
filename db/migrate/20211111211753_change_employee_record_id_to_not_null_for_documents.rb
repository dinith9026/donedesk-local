class ChangeEmployeeRecordIdToNotNullForDocuments < ActiveRecord::Migration[5.2]
  def change
    change_column_null :documents, :employee_record_id, true
  end
end
