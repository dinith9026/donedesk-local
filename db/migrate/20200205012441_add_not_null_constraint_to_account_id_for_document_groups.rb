class AddNotNullConstraintToAccountIdForDocumentGroups < ActiveRecord::Migration[5.0]
  def change
    change_column_null :document_groups, :account_id, false
  end
end
