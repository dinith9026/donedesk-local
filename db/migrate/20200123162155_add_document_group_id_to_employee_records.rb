class AddDocumentGroupIdToEmployeeRecords < ActiveRecord::Migration[5.0]
  def up
    add_reference :employee_records, :document_group, type: :uuid, index: true, foreign_key: true

    accounts = select_all 'SELECT * FROM accounts'

    accounts.each do |account|
      document_types = select_all "SELECT * FROM document_types WHERE account_id IS NULL OR account_id = '#{account['id']}'"

      document_group_id = insert "INSERT INTO document_groups (title, account_id, created_at, updated_at) VALUES ('Default', '#{account['id']}', NOW(), NOW())"

      document_types.each do |document_type|
        insert "INSERT INTO document_types_groupings (document_type_id, document_group_id, required, created_at, updated_at) VALUES ('#{document_type['id']}', '#{document_group_id}', #{document_type['required']}, NOW(), NOW())"
      end

      employee_records = select_all "SELECT employee_records.* FROM employee_records JOIN offices ON employee_records.office_id = offices.id WHERE offices.account_id = '#{account['id']}'"

      employee_records.each do |employee_record|
        update "UPDATE employee_records SET document_group_id = '#{document_group_id}' WHERE id = '#{employee_record['id']}'"
      end
    end

    change_column_null :employee_records, :document_group_id, false
  end

  def down
    remove_reference :employee_records, :document_group, index: true, foreign_key: true
    execute "DELETE FROM document_types_groupings"
    execute "DELETE FROM document_groups"
  end
end
