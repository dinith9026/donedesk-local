class EmployeeComplianceSummary
  attr_reader :expired_documents, :expiring_documents, :expired_course_assignments,
    :expiring_course_assignments, :incomplete_course_assignments, :missing_required_documents

  def initialize(employee_record)
    @employee_record = employee_record
    @expired_documents = filter_confidential(employee_record.expired_documents)
    @expiring_documents = filter_confidential(employee_record.documents_expiring_soon)
    @expired_course_assignments = employee_record.expired_course_assignments
    @expiring_course_assignments = employee_record.expiring_course_assignments
    @incomplete_course_assignments = employee_record.incomplete_assignments
    @missing_required_documents = filter_confidential(employee_record.missing_documents)
  end

  def compliant?
    @expired_documents.none? &&
      @expiring_documents.none? &&
      @expired_course_assignments.none? &&
      @expiring_course_assignments.none? &&
      @incomplete_course_assignments.none? &&
      @missing_required_documents.none?
  end

  private

  def filter_confidential(documents)
    documents.reject { |document| document.is_confidential }
  end
end
