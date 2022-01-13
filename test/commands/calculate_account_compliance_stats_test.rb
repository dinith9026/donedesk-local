require 'test_helper'

class CalculateAccountComplianceStatsTest < CommandTest
  test 'when no stats have been calculated yet' do
    count_before = AccountComplianceStats.count
    account = accounts(:oceanview_dental)

    assert_broadcast(:ok) { CalculateAccountComplianceStats.call(account) }
    assert_equal count_before + 1, AccountComplianceStats.count
  end

  test 'when stats have already been calculated yet' do
    account = accounts(:oceanview_dental)
    stats = create(:account_compliance_stats, account: account)
    document_compliance_percentage_before = stats.document_compliance_percentage
    training_compliance_percentage_before = stats.training_compliance_percentage
    count_before = AccountComplianceStats.count

    assert_broadcast(:ok) { CalculateAccountComplianceStats.call(account) }

    stats.reload

    assert_equal count_before, AccountComplianceStats.count
    refute_equal document_compliance_percentage_before, stats.document_compliance_percentage
    refute_equal training_compliance_percentage_before, stats.training_compliance_percentage
  end
end
