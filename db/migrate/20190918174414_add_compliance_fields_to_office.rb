class AddComplianceFieldsToOffice < ActiveRecord::Migration[5.0]
  def change
    add_column :offices, :document_compliance_percentage, :integer, null: false, default: 0
    add_column :offices, :training_compliance_percentage, :integer, null: false, default: 0
  end
end
