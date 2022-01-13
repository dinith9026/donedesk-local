class AddAppliesToToDocumentGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :document_groups, :applies_to, :string, null: false, default: 'employees'
  end
end
