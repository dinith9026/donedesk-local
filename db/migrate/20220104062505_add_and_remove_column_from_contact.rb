class AddAndRemoveColumnFromContact < ActiveRecord::Migration[5.2]
  def change
    remove_column :contacts, :contact_name
    add_column :contacts, :first_name, :string, null: false
    add_column :contacts, :last_name, :string, null: false
    add_reference :contacts, :office, index: true, foreign_key: true, type: :uuid
  end
end
