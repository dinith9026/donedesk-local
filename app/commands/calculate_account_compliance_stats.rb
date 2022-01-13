class CalculateAccountComplianceStats < ApplicationCommand
  def initialize(account)
    @account = account
  end

  def call
    document_compliance_percentage = DocumentCompliance.new(@account.active_employee_records).percentage
    training_compliance_percentage = TrainingCompliance.new(@account.active_employee_records).percentage

    AccountComplianceStats
    .find_or_initialize_by(account_id: @account.id)
    .update!(
      document_compliance_percentage: document_compliance_percentage,
      training_compliance_percentage: training_compliance_percentage
    )

    broadcast(:ok)
  end
end
