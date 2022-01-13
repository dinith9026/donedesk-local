require 'test_helper'

class CalculateAccountExpiredDocumentsTest < CommandTest
  test 'when no expired documents have been calculated yet' do
    count_before = ExpiredDocument.count
    account = accounts(:oceanview_dental)

    assert_broadcast(:ok) { CalculateAccountExpiredDocuments.call(account) }
    assert ExpiredDocument.count > count_before
  end

  test 'when expired documents have already been calculated' do
    ExpiredDocument.create!(employee_record: employee_records(:ed), document_type: document_types(:w4))
    account = accounts(:oceanview_dental)
    expired_documents = ExpiredDocuments.new(account.active_employee_records).count

    assert_broadcast(:ok) { CalculateAccountExpiredDocuments.call(account) }
    assert_equal expired_documents, ExpiredDocument.count
  end
end
