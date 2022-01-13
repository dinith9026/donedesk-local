class AddDocumentGroupIdToOffices < ActiveRecord::Migration[5.2]
  def up
    add_reference :offices, :document_group, type: :uuid, index: true, foreign_key: true

    document_type_id = insert("INSERT INTO document_types (name, applies_to, created_at, updated_at) VALUES ('Maintenance Checklist', 'offices', NOW(), NOW())")

    accounts = select_all("SELECT * FROM accounts")

    accounts.each do |account|
      document_group_id = insert("INSERT INTO document_groups (name, applies_to, account_id, created_at, updated_at) VALUES ('Default Group for Offices (recommended)', 'offices', '#{account['id']}', NOW(), NOW())")
      insert("INSERT INTO document_types_groupings (document_type_id, document_group_id, required, created_at, updated_at) VALUES ('#{document_type_id}', '#{document_group_id}', false, NOW(), NOW())")

      account_offices = select_all "SELECT * FROM offices WHERE offices.account_id = '#{account['id']}'"

      account_offices.each do |account_office|
        update("UPDATE offices SET document_group_id = '#{document_group_id}' WHERE id = '#{account_office['id']}'")
      end
    end

    change_column_null :offices, :document_group_id, false
  end

  def down
    remove_reference :offices, :document_group, index: true, foreign_key: true
    execute "DELETE FROM document_groups WHERE name = 'Default Group for Offices (recommended)'"
    execute "DELETE FROM document_types WHERE name = 'Maintenance Checklist' AND applies_to = 'offices' AND account_id IS NULL"
  end
end
