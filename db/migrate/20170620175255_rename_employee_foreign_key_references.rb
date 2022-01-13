class RenameEmployeeForeignKeyReferences < ActiveRecord::Migration[5.0]
  def change
    rename_column :assignments, :employee_id, :employee_record_id
    rename_column :documents, :employee_id, :employee_record_id
  end
end
