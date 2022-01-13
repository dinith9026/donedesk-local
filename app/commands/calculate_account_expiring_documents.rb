class CalculateAccountExpiringDocuments < ApplicationCommand
  def initialize(account)
    @account = account
  end

  def call
    ExpiringDocument.where(employee_record_id: @account.employee_records.ids).destroy_all

    @account.active_employee_records.each do |employee_record|
      employee_record.documents_expiring_soon.each do |document|
        ExpiringDocument.create!(
          employee_record_id: employee_record.id,
          document_type_id: document.document_type_id,
          days_until_expiry: document.expires_in
        )
      end
    end

    broadcast(:ok)
  end
end
