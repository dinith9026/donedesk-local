class AccountComplianceSummary
  attr_reader :expired_documents, :expiring_documents, :expired_course_assignments,
    :expiring_course_assignments, :incomplete_course_assignments

  def initialize(account)
    @account = account
    @expired_documents = []
    @expiring_documents = []
    @expired_course_assignments = []
    @expiring_course_assignments = []
    @incomplete_course_assignments = []

    summarize
  end

  private

  def summarize
    @account.active_employee_records.each do |employee_record|
      @expired_documents << employee_record.expired_documents
      @expiring_documents << employee_record.documents_expiring_soon
      @expired_course_assignments << employee_record.expired_course_assignments
      @expiring_course_assignments << employee_record.expiring_course_assignments
      @incomplete_course_assignments << employee_record.incomplete_assignments
    end

    @expired_documents = @expired_documents.flatten
    @expiring_documents = @expiring_documents.flatten
    @expired_course_assignments = @expired_course_assignments.flatten
    @expiring_course_assignments = @expiring_course_assignments.flatten
    @incomplete_course_assignments = @incomplete_course_assignments.flatten
  end
end
