require 'test_helper'

class CalculateAccountMissingDocumentsTest < CommandTest
  test 'when no missing documents have been calculated yet' do
    count_before = MissingDocument.count
    account = accounts(:oceanview_dental)

    assert_broadcast(:ok) { CalculateAccountMissingDocuments.call(account) }
    assert MissingDocument.count > count_before
  end

  test 'when missing documents have already been calculated' do
    MissingDocument.create!(employee_record: employee_records(:ed), document_type: document_types(:w4))
    account = accounts(:oceanview_dental)
    missing_documents = MissingDocuments.new(account.active_employee_records).count

    assert_broadcast(:ok) { CalculateAccountMissingDocuments.call(account) }
    assert_equal missing_documents, MissingDocument.count
  end
end
