class DocumentCompliance
  def initialize(employee_records)
    @employee_records = employee_records.reject(&:nil?)
    @total_required = 0
    @missing = 0
    @expired = 0
    calculate
  end

  def percentage
    if @total_required == 0
      0
    else
      (compliance_percentage * 100).floor
    end
  end

  private

  def calculate
    @employee_records.each do |employee_record|
      @total_required += employee_record.required_documents.count
      @missing += employee_record.missing_documents.count
      @expired += employee_record.expired_documents.count
    end
  end

  def missing_and_expired
    @expired + @missing
  end

  def non_compliance_percentage
    missing_and_expired.to_f / @total_required.to_f
  end

  def compliance_percentage
    (1 - non_compliance_percentage)
  end
end
