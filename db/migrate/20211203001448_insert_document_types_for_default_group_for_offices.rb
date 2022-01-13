class InsertDocumentTypesForDefaultGroupForOffices < ActiveRecord::Migration[5.2]
  def up
    document_type_names.each do |document_type_name|
      document_type_id = insert("INSERT INTO document_types (name, applies_to, created_at, updated_at) VALUES ('#{document_type_name}', 'offices', NOW(), NOW())")

      accounts = select_all("SELECT * FROM accounts")

      accounts.each do |account|
        document_group_id = select_value("SELECT id FROM document_groups WHERE name = 'Default Group for Offices (recommended)' AND account_id = '#{account['id']}'")
        insert("INSERT INTO document_types_groupings (document_type_id, document_group_id, required, created_at, updated_at) VALUES ('#{document_type_id}', '#{document_group_id}', false, NOW(), NOW())")
      end
    end
  end

  def down
    document_type_names.each do |document_type_name|
      document_type_id = select_value("SELECT id FROM document_types WHERE name = '#{document_type_name}' AND applies_to = 'offices'")

      accounts = select_all("SELECT * FROM accounts")

      accounts.each do |account|
        document_group_id = select_value("SELECT id FROM document_groups WHERE name = 'Default Group for Offices (recommended)' AND account_id = '#{account['id']}'")
        execute("DELETE FROM document_types_groupings WHERE document_type_id = '#{document_type_id}' AND document_group_id = '#{document_group_id}'")
      end

      execute("DELETE FROM document_types WHERE name = '#{document_type_name}' AND applies_to = 'offices' AND account_id IS NULL")
    end
  end

  def document_type_names
    [
      'Business Creation Documents',
      'Business Insurance Policy',
      'Professional Liability Insurance',
      'Health Insurance Documents',
      'Vendor Agreements',
      'Supplier Proposals',
      'Company Bylaws',
      'State Registration Documents',
      'Radiation QA/QC Checklist',
      'Business License',
      'Minutes for Your Business Meeting',
      'Financial Documents',
      'Lease Agreement',
      'Agreement Templates'
    ]
  end
end
