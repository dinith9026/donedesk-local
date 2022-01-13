require 'test_helper'

class DocumentComplianceTest < ActiveSupport::TestCase
  class EmployeeRecordStub
    def initialize(employed: true, required_documents: [], missing_documents: [],
                   expired_documents: [], documents_expiring_soon: [])
      @employed = employed
      @required_documents = required_documents
      @missing_documents = missing_documents
      @expired_documents = expired_documents
      @documents_expiring_soon = documents_expiring_soon
    end

    attr_reader :employed, :required_documents, :missing_documents,
                :expired_documents, :documents_expiring_soon

    def employed?
      employed
    end
  end

  describe '#percentage' do
    test 'when employee array contains nil' do
      subject = DocumentCompliance.new([nil])

      assert_equal 0, subject.percentage
    end

    test 'when no active employees' do
      subject = DocumentCompliance.new([])

      assert_equal 0, subject.percentage
    end

    test 'when all documents are missing' do
      employee_record_stub =
        EmployeeRecordStub.new(required_documents: [1], missing_documents: [1])

      subject = DocumentCompliance.new([employee_record_stub])

      assert_equal 0, subject.percentage
    end

    test 'when all documents are expired' do
      employee_record_stub =
        EmployeeRecordStub.new(required_documents: [1], expired_documents: [1])

      subject = DocumentCompliance.new([employee_record_stub])

      assert_equal 0, subject.percentage
    end

    test 'when some required documents are present and not expired' do
      employee_record_stub =
        EmployeeRecordStub.new(required_documents: [1, 2, 3],
                               missing_documents: [1],
                               expired_documents: [1])

      subject = DocumentCompliance.new([employee_record_stub])

      assert_equal 33, subject.percentage
    end

    test 'when all required documents are present and not expired' do
      employee_record_stub = EmployeeRecordStub.new(required_documents: [1, 2, 3])

      subject = DocumentCompliance.new([employee_record_stub])

      assert_equal 100, subject.percentage
    end
  end
end
