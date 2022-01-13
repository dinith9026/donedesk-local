class AddComplianceExpirationInDaysToCourse < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :compliance_expiration_in_days, :integer, null: false, default: 0
  end
end
