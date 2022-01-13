require 'test_helper'

class AccountComplianceSummaryTest < ActiveSupport::TestCase
  describe '#expired_documents' do
    test 'when none exist' do
      summary = AccountComplianceSummary.new(Account.new)

      assert_equal [], summary.expired_documents
    end

    test 'when some exist' do
      account = accounts(:oceanview_dental)
      expired_document_for_employed_employee = employee_documents(:oceanview_ed_expired)
      expired_confidential_document_for_employed_employee = employee_documents(:oceanview_ed_expired_confidential)
      expired_document_for_terminated_employee = employee_documents(:oceanview_terminated_expired)
      expired_document_for_other_account = employee_documents(:brookside_ellen_expired)
      summary = AccountComplianceSummary.new(account)

      result = summary.expired_documents

      assert_equal 2, result.count
      assert_includes result, expired_document_for_employed_employee
      assert_includes result, expired_confidential_document_for_employed_employee
      refute_includes result, expired_document_for_terminated_employee
      refute_includes result, expired_document_for_other_account
    end
  end

  describe '#expiring_documents' do
    test 'when none exist' do
      summary = AccountComplianceSummary.new(Account.new)

      assert_equal [], summary.expiring_documents
    end

    test 'when some exist' do
      account = accounts(:oceanview_dental)
      expiring_document_for_employed_employee = employee_documents(:oceanview_eric_expiring)
      expiring_document_for_terminated_employee = employee_documents(:oceanview_terminated_expiring)
      expiring_document_for_other_account = employee_documents(:brookside_ellen_expiring)
      summary = AccountComplianceSummary.new(account)

      result = summary.expiring_documents

      assert_equal 1, result.count
      assert_equal expiring_document_for_employed_employee, result.first
      refute_includes result, expiring_document_for_terminated_employee
      refute_includes result, expiring_document_for_other_account
    end
  end

  describe '#expired_course_assignments' do
    test 'when none exist' do
      summary = AccountComplianceSummary.new(Account.new)

      assert_equal [], summary.expired_course_assignments
    end

    test 'when some exist' do
      account = accounts(:oceanview_dental)
      expired_course_assignment = assignments(:oceanview_ed_expired)
      summary = AccountComplianceSummary.new(account)

      result = summary.expired_course_assignments

      assert_equal 1, result.count
      assert_includes result, expired_course_assignment
    end
  end

  describe '#expiring_course_assignments' do
    test 'when none exist' do
      summary = AccountComplianceSummary.new(Account.new)

      assert_equal [], summary.expiring_course_assignments
    end

    test 'when some exist' do
      account = accounts(:oceanview_dental)
      expiring_course_assignment = assignments(:oceanview_eric_expiring)
      summary = AccountComplianceSummary.new(account)

      result = summary.expiring_course_assignments

      assert_equal 1, result.count
      assert_includes result, expiring_course_assignment
    end
  end

  describe '#incomplete_course_assignments' do
    test 'when none exist' do
      summary = AccountComplianceSummary.new(Account.new)

      assert_equal [], summary.incomplete_course_assignments
    end

    test 'when some exist' do
      account = accounts(:oceanview_dental)
      summary = AccountComplianceSummary.new(account)

      result = summary.incomplete_course_assignments

      refute_equal [], result.count
    end
  end
end
