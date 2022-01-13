require 'test_helper'

class CalculateOfficeComplianceStatsTest < CommandTest
  test 'when no stats have been calculated yet' do
    office = offices(:oceanview_tx)

    assert_broadcast(:ok) { CalculateOfficeComplianceStats.call(office) }
    assert office.reload.document_compliance_percentage > 0
    assert office.reload.training_compliance_percentage > 0
  end

  test 'when stats have already been calculated' do
    office = offices(:oceanview_tx)
    office.document_compliance_percentage = 1
    office.training_compliance_percentage = 1
    office.save!

    assert_broadcast(:ok) { CalculateOfficeComplianceStats.call(office) }

    office.reload

    refute_equal office.document_compliance_percentage, 1
    refute_equal office.training_compliance_percentage, 1
  end
end
