class CalculateOfficeComplianceStats < ApplicationCommand
  def initialize(office)
    @office = office
  end

  def call
    document_compliance_percentage = DocumentCompliance.new(@office.employed_employees).percentage
    training_compliance_percentage = TrainingCompliance.new(@office.employed_employees).percentage

    @office.update!(
      document_compliance_percentage: document_compliance_percentage,
      training_compliance_percentage: training_compliance_percentage
    )

    broadcast(:ok)
  end
end
