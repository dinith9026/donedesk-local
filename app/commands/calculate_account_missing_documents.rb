class CalculateAccountMissingDocuments < ApplicationCommand
  def initialize(account)
    @account = account
  end

  def call
    MissingDocument.where(employee_record_id: @account.employee_records.ids).destroy_all

    @account.active_employee_records.each do |employee_record|
      employee_record.missing_documents.each do |document_type|
        MissingDocument.create!(
          employee_record_id: employee_record.id,
          document_type_id: document_type.id
        )
      end
    end

    broadcast(:ok)
  end
end
