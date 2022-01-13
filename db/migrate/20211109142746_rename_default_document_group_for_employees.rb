class RenameDefaultDocumentGroupForEmployees < ActiveRecord::Migration[5.2]
  def up
    execute "UPDATE document_groups SET name = 'Default Group for Employees (recommended)' WHERE name = 'Default'"
  end

  def down
    execute "UPDATE document_groups SET name = 'Default' WHERE name = 'Default Group for Employees (recommended)'"
  end
end
