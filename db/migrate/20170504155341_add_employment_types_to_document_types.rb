class AddEmploymentTypesToDocumentTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :document_types, :employment_types_value, :integer, default: 0
  end
end
