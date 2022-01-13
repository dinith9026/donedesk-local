class RenamePhoneField < ActiveRecord::Migration[5.0]
  def change
    rename_column :employees, :phone_number, :phone
  end
end
