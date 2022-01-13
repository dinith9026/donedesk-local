class AddDefaultForRequiredFieldOnDocumentTypesGroupings < ActiveRecord::Migration[5.0]
  def up
    execute "UPDATE document_types_groupings SET required = FALSE WHERE required IS NULL"
    change_column_null(:document_types_groupings, :required, false, false)
  end

  def down
    change_column_null(:document_types_groupings, :required, true)
  end
end
