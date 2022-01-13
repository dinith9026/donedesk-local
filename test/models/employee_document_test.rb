require 'test_helper'

class EmployeeDocumentTest < ActiveSupport::TestCase
  should validate_presence_of(:employee_record_id)
  should validate_presence_of(:document_id)

  describe 'scopes' do
    describe '.search' do
      test 'no match' do
        results = EmployeeDocument.search('no match')

        assert_equal 0, results.length
      end

      test 'employee first name match' do
        eric = employee_records(:eric)

        results = EmployeeDocument.search(eric.first_name.upcase)

        assert_equal eric.employee_documents.length, results.length
        eric.employee_documents.each do |document|
          assert_includes results, document
        end
      end

      test 'employee last name match' do
        eric = employee_records(:eric)
        last_name = SecureRandom.uuid
        eric.update!(last_name: last_name)

        results = EmployeeDocument.search(last_name.upcase)

        assert_equal eric.employee_documents.length, results.length
        eric.employee_documents.each do |document|
          assert_includes results, document
        end
      end

      test 'document type name match' do
        w4 = document_types(:w4)

        results = EmployeeDocument.search(w4.name.upcase)

        assert_equal w4.documents.length, results.length
        w4.employee_documents.each do |document|
          assert_includes results, document
        end
      end
   end
  end
end
