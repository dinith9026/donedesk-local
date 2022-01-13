class CalculateAccountExpiredDocuments < ApplicationCommand
  def initialize(account)
    @account = account
  end

  def call
    ExpiredDocument.where(employee_record_id: @account.employee_records.ids).destroy_all

    @account.active_employee_records.each do |employee_record|
      employee_record.expired_documents.each do |document|
        ExpiredDocument.create!(
          employee_record_id: employee_record.id,
          document_type_id: document.document_type_id
        )
      end
    end

    broadcast(:ok)
  end
end
