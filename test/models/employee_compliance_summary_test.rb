require 'test_helper'

class EmployeeComplianceSummaryTest < ActiveSupport::TestCase
  setup do
    @employee_record = employee_records(:ed)
  end

  describe '#expired_documents' do
    test 'when none exist' do
      @employee_record.stubs(:expired_documents).returns([])
      summary = EmployeeComplianceSummary.new(@employee_record)

      assert_equal [], summary.expired_documents
    end

    test 'when some exist' do
      expired_document_for_employee = employee_documents(:oceanview_ed_expired)
      expired_confidential_document_for_employee = employee_documents(:oceanview_ed_expired_confidential)
      expired_document_for_other_employee = employee_documents(:brookside_ellen_expired)
      summary = EmployeeComplianceSummary.new(@employee_record)

      result = summary.expired_documents

      assert_equal 1, result.count
      assert_includes result, expired_document_for_employee
      refute_includes result, expired_confidential_document_for_employee
      refute_includes result, expired_document_for_other_employee
    end
  end

  describe '#expiring_documents' do
    test 'when none exist' do
      @employee_record.stubs(:documents_expiring_soon).returns([])
      summary = EmployeeComplianceSummary.new(@employee_record)

      assert_equal [], summary.expiring_documents
    end

    test 'when some exist' do
      employee_record = employee_records(:eric)
      expiring_document_for_employee = employee_documents(:oceanview_eric_expiring)
      expiring_document_for_other_employee = employee_documents(:brookside_ellen_expiring)
      summary = EmployeeComplianceSummary.new(employee_record)

      result = summary.expiring_documents

      assert_equal 1, result.count
      assert_includes result, expiring_document_for_employee
      refute_includes result, expiring_document_for_other_employee
    end
  end

  describe '#expired_course_assignments' do
    test 'when none exist' do
      @employee_record.stubs(:expired_course_assignments).returns([])
      summary = EmployeeComplianceSummary.new(@employee_record)

      assert_equal [], summary.expired_course_assignments
    end

    test 'when some exist' do
      expired_course_assignment = assignments(:oceanview_ed_expired)
      summary = EmployeeComplianceSummary.new(@employee_record)

      result = summary.expired_course_assignments

      assert_equal 1, result.count
      assert_includes result, expired_course_assignment
    end
  end

  describe '#expiring_course_assignments' do
    test 'when none exist' do
      @employee_record.stubs(:expiring_course_assignments).returns([])
      summary = EmployeeComplianceSummary.new(@employee_record)

      assert_equal [], summary.expiring_course_assignments
    end

    test 'when some exist' do
      employee_record = employee_records(:eric)
      expiring_course_assignment = assignments(:oceanview_eric_expiring)
      summary = EmployeeComplianceSummary.new(employee_record)

      result = summary.expiring_course_assignments

      assert_equal 1, result.count
      assert_includes result, expiring_course_assignment
    end
  end

  describe '#incomplete_course_assignments' do
    test 'when none exist' do
      @employee_record.stubs(:incomplete_assignments).returns([])
      summary = EmployeeComplianceSummary.new(@employee_record)

      assert_equal [], summary.incomplete_course_assignments
    end

    test 'when some exist' do
      incomplete_assignment = assignments(:oceanview_ed_incomplete)
      summary = EmployeeComplianceSummary.new(@employee_record)

      result = summary.incomplete_course_assignments

      assert_equal @employee_record.incomplete_assignments.count, result.count
      assert_includes result, incomplete_assignment
    end
  end

  describe '#missing_required_documents' do
    test 'when none exist' do
      @employee_record.stubs(:missing_documents).returns([])
      summary = EmployeeComplianceSummary.new(@employee_record)

      assert_equal [], summary.missing_required_documents
    end

    test 'when some exist' do
      required = document_types(:oceanview_required)
      required_confidential = document_types(:oceanview_confidential)
      EmployeeDocument
        .joins(:document)
        .where('documents.document_type_id IN (?)', [required.id, required_confidential.id])
        .where(employee_record_id: @employee_record.id)
        .delete_all
      summary = EmployeeComplianceSummary.new(@employee_record)

      result = summary.missing_required_documents

      assert_includes result, required
      refute_includes result, required_confidential
    end
  end

  describe '#compliant?' do
    test 'when there are only expired documents' do
      document_stub = Document.new
      document_stub.stubs(:is_confidential).returns(false)
      @employee_record.stubs(:expired_documents).returns([document_stub])
      @employee_record.stubs(:documents_expiring_soon).returns([])
      @employee_record.stubs(:expired_course_assignments).returns([])
      @employee_record.stubs(:expiring_course_assignments).returns([])
      @employee_record.stubs(:incomplete_assignments).returns([])
      @employee_record.stubs(:missing_documents).returns([])

      summary = EmployeeComplianceSummary.new(@employee_record)

      assert_equal false, summary.compliant?
    end

    test 'when there are only expiring documents' do
      document_stub = Document.new
      document_stub.stubs(:is_confidential).returns(false)
      @employee_record.stubs(:expired_documents).returns([])
      @employee_record.stubs(:documents_expiring_soon).returns([document_stub])
      @employee_record.stubs(:expired_course_assignments).returns([])
      @employee_record.stubs(:expiring_course_assignments).returns([])
      @employee_record.stubs(:incomplete_assignments).returns([])
      @employee_record.stubs(:missing_documents).returns([])

      summary = EmployeeComplianceSummary.new(@employee_record)

      assert_equal false, summary.compliant?
    end

    test 'when there are only expired course assignments' do
      @employee_record.stubs(:expired_documents).returns([])
      @employee_record.stubs(:documents_expiring_soon).returns([])
      @employee_record.stubs(:expired_course_assignments).returns([Assignment.new])
      @employee_record.stubs(:expiring_course_assignments).returns([])
      @employee_record.stubs(:incomplete_assignments).returns([])
      @employee_record.stubs(:missing_documents).returns([])

      summary = EmployeeComplianceSummary.new(@employee_record)

      assert_equal false, summary.compliant?
    end

    test 'when there are only expiring course assignments' do
      @employee_record.stubs(:expired_documents).returns([])
      @employee_record.stubs(:documents_expiring_soon).returns([])
      @employee_record.stubs(:expired_course_assignments).returns([])
      @employee_record.stubs(:expiring_course_assignments).returns([Assignment.new])
      @employee_record.stubs(:incomplete_assignments).returns([])
      @employee_record.stubs(:missing_documents).returns([])

      summary = EmployeeComplianceSummary.new(@employee_record)

      assert_equal false, summary.compliant?
    end

    test 'when there are only incomplete assignments' do
      @employee_record.stubs(:expired_documents).returns([])
      @employee_record.stubs(:documents_expiring_soon).returns([])
      @employee_record.stubs(:expired_course_assignments).returns([])
      @employee_record.stubs(:expiring_course_assignments).returns([])
      @employee_record.stubs(:incomplete_assignments).returns([Assignment.new])
      @employee_record.stubs(:missing_documents).returns([])

      summary = EmployeeComplianceSummary.new(@employee_record)

      assert_equal false, summary.compliant?
    end

    test 'when there are only missing required documents' do
      @employee_record.stubs(:expired_documents).returns([])
      @employee_record.stubs(:documents_expiring_soon).returns([])
      @employee_record.stubs(:expired_course_assignments).returns([])
      @employee_record.stubs(:expiring_course_assignments).returns([])
      @employee_record.stubs(:incomplete_assignments).returns([])
      @employee_record.stubs(:missing_documents).returns([DocumentType.new])

      summary = EmployeeComplianceSummary.new(@employee_record)

      assert_equal false, summary.compliant?
    end

    test 'when there are no expired or expired documents or courses or incomplete assignments' do
      @employee_record.stubs(:expired_documents).returns([])
      @employee_record.stubs(:documents_expiring_soon).returns([])
      @employee_record.stubs(:expired_course_assignments).returns([])
      @employee_record.stubs(:expiring_course_assignments).returns([])
      @employee_record.stubs(:incomplete_assignments).returns([])
      @employee_record.stubs(:missing_documents).returns([])

      summary = EmployeeComplianceSummary.new(@employee_record)

      assert_equal true, summary.compliant?
    end
  end
end
