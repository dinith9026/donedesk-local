require 'test_helper'

class ExpiredDocumentsTest < ActiveSupport::TestCase
  test 'when no expired documents exist' do
    employee_record = build(:employee_record)
    employee_record.stubs(:has_expired_documents?).returns(false)

    result = ExpiredDocuments.new([employee_record])

    assert_equal 0, result.count
  end

  test 'when expired documents exist' do
    document = build(:document)
    employee_record = build(:employee_record)
    employee_record.stubs(:has_expired_documents?).returns(true)
    employee_record.stubs(:expired_documents).returns([document])

    result = ExpiredDocuments.new([employee_record])

    assert_equal 1, result.count
    assert_equal document.name, result.first.name
  end
end
