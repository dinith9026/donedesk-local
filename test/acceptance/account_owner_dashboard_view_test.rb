require 'test_helper'
require_relative './account_admins_dashboard_view_tests'

class AccountOwnerDashboardViewTest < AcceptanceTestCase
  include ActionDispatch::TestProcess
  setup do
    @user = users(:account_owner)
  end

  extend AccountAdminsDashboardViewTests

  test 'when no employee records exist yet' do
    account = create(:account)

    sign_in_with(account.owner)
    click_on 'Dashboard'

    assert_content 'Welcome'
    assert_content 'Get started by creating your first employee'
    refute_content 'Document Compliance'
    refute_content 'Training Compliance'
  end

  describe 'when employee records exist' do
    setup do
      @account = create(:account)
      @document_group = create_employee_document_group_for(@account)

      @employed = create(
        :employee_record,
        :employed,
        user: @account.users.first,
        office: @account.offices.first,
        document_group: @document_group,
        documents: [])
    end

    test '0% document compliance' do
      CalculateAccountComplianceStats.call(@account)

      sign_in_with(@account.owner)
      click_on 'Dashboard'

      assert_content '0% Overall Document Compliance'
    end

    test '50% document compliance' do
      total_required = @employed.required_documents.count
      half = ((total_required/2) - 1)

      @employed.required_documents[0..half].each do |required_document_type|
        document = create(
          :document,
          document_type: required_document_type,
          file: file
        )

        create(
          :employee_document,
          employee_record: @employed,
          document: document
        )
      end

      CalculateAccountComplianceStats.call(@account)

      sign_in_with(@account.owner)
      click_on 'Dashboard'

      assert_content '50% Overall Document Compliance'
    end

    test '100% document compliance' do
      @employed.required_documents.each do |required_document_type|
        document = create(
          :document,
          document_type: required_document_type,
          file: file
        )

        create(
          :employee_document,
          employee_record: @employed,
          document: document
        )
      end

      CalculateAccountComplianceStats.call(@account)

      sign_in_with(@account.owner)
      click_on 'Dashboard'

      assert_content '100% Overall Document Compliance'
    end
  end

  private

  def file
    fixture_file_upload('test.pdf', 'application/pdf')
  end
end
