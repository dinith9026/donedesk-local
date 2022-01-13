class ChangeFieldsToCitext < ActiveRecord::Migration[5.0]
  def up
    change_column :courses, :title, :citext
    change_column :document_group_presets, :name, :citext, unique: true
    change_column :document_groups, :name, :citext
    change_column :document_types, :name, :citext
    change_column :employee_records, :first_name, :citext
    change_column :employee_records, :last_name, :citext
    change_column :employee_records, :title, :citext
    change_column :library_documents, :name, :citext
    change_column :offices, :name, :citext
    change_column :offices, :street_address, :citext
    change_column :offices, :address2, :citext
    change_column :offices, :city, :citext
    change_column :offices, :state, :citext
    change_column :users, :email, :citext
    change_column :users, :first_name, :citext
    change_column :users, :last_name, :citext
  end

  def down
    change_column :courses, :title, :string
    change_column :document_group_presets, :name, :string, unique: false
    change_column :document_groups, :name, :string
    change_column :document_types, :name, :string
    change_column :employee_records, :first_name, :string
    change_column :employee_records, :last_name, :string
    change_column :employee_records, :title, :string
    change_column :library_documents, :name, :string
    change_column :offices, :name, :string
    change_column :offices, :street_address, :string
    change_column :offices, :address2, :string
    change_column :offices, :city, :string
    change_column :offices, :state, :string
    change_column :users, :email, :string
    change_column :users, :first_name, :string
    change_column :users, :last_name, :string
  end
end
