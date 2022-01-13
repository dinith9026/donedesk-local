require 'test_helper'

class ExpiringDocumentsTest < ActiveSupport::TestCase
  test 'when no expiring documents exist' do
    employee_record = build(:employee_record)
    employee_record.stubs(:has_documents_expiring_soon?).returns(false)

    result = ExpiringDocuments.new([employee_record])

    assert_equal 0, result.count
  end

  test 'when expiring documents exist' do
    document = build(:document)
    employee_record = build(:employee_record)
    employee_record.stubs(:has_documents_expiring_soon?).returns(true)
    employee_record.stubs(:documents_expiring_soon).returns([document])

    result = ExpiringDocuments.new([employee_record])

    assert_equal 1, result.count
    assert_equal document.name, result.first.name
  end
end
