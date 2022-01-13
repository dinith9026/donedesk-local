require 'test_helper'

class CalculateAccountExpiringDocumentsTest < CommandTest
  test 'when no expiring documents have been calculated yet' do
    count_before = ExpiringDocument.count
    account = accounts(:oceanview_dental)

    assert_broadcast(:ok) { CalculateAccountExpiringDocuments.call(account) }
    assert ExpiringDocument.count > count_before
  end

  test 'when expiring documents have already been calculated' do
    ExpiringDocument.create!(employee_record: employee_records(:ed), document_type: document_types(:w4), days_until_expiry: 20)
    account = accounts(:oceanview_dental)
    expiring_documents = ExpiringDocuments.new(account.active_employee_records).count

    assert_broadcast(:ok) { CalculateAccountExpiringDocuments.call(account) }
    assert_equal expiring_documents, ExpiringDocument.count
  end
end
