require 'test_helper'

class MissingDocumentsTest < ActiveSupport::TestCase
  test 'when no documents are missing' do
    employee_record = build(:employee_record)
    employee_record.stubs(:has_missing_documents?).returns(false)

    result = MissingDocuments.new([employee_record])

    assert_equal 0, result.count
  end

  test 'when documents are missing' do
    document_type = build(:document_type)
    employee_record = build(:employee_record)
    employee_record.stubs(:has_missing_documents?).returns(true)
    employee_record.stubs(:missing_documents).returns([document_type])

    result = MissingDocuments.new([employee_record])

    assert_equal 1, result.count
    assert_equal document_type.name, result.first.name
  end
end
