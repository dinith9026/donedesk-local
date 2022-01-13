class RenameTerminateAtToTerminatedOn < ActiveRecord::Migration[5.0]
  def change
    rename_column :employee_records, :terminated_at, :terminated_on
  end
end
