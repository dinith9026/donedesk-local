class TrainingCompliance
  def initialize(employee_records)
    @employee_records = employee_records.reject(&:nil?)
  end

  def percentage
    if active_assignments.none?
      0
    else
      (compliance_percentage * 100).floor
    end
  end

  private

  def incomplete
    @employee_records.inject(0) do |sum, employee_record|
      sum += employee_record.incomplete_assignments.count
    end
  end

  def non_compliance_percentage
    incomplete.to_f / active_assignments.count.to_f
  end

  def compliance_percentage
    (1 - non_compliance_percentage)
  end

  def active_assignments
    @employee_records.map(&:active_assignments).flatten
  end
end
