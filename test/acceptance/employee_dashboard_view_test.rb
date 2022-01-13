require 'test_helper'

class EmployeeDashboardViewTest < AcceptanceTestCase
  include ActionDispatch::TestProcess

  test 'when no employee record exists yet' do
    account = create(:account)
    employee_user = create(:user, :employee, account: account)

    sign_in_with(employee_user)
    click_on 'Dashboard'

    assert_content 'New Employee Record'
    refute_content 'Document Compliance'
    refute_content 'Training Compliance'
  end

  describe 'when employee record exists' do
    setup do
      @account = create(:account)
      @employee_user = create(:user, :employee, account: @account)
      @course1 = create(:course, :with_question, account: @account)
      @course2 = create(:course, :with_question, account: @account)
      @document_group = create_employee_document_group_for(@account)

      @employed = create(
        :employee_record,
        :employed,
        user: @employee_user,
        office: @account.offices.first,
        document_group: @document_group,
        documents: [])
    end

    test '0% document and training compliance' do
      sign_in_with(@employee_user)
      click_on 'Dashboard'

      refute_content '0% Overall Document Compliance'
      assert_content '0% Overall Training Compliance'
    end

    test '50% document and training compliance' do
      create(:assignment, :new, employee_record: @employed, course: @course1)
      create(:assignment, :passed, employee_record: @employed, course: @course2)

      total_required = @employed.required_documents.count
      half = ((total_required/2) - 1)

      @employed.required_documents[0..half].each do |required_document_type|
        document = create(
          :document,
          document_type: required_document_type,
          file: file)

        create(
          :employee_document,
          employee_record: @employed,
          document: document
        )
      end

      sign_in_with(@employee_user)
      click_on 'Dashboard'

      refute_content '50% Overall Document Compliance'
      assert_content '50% Overall Training Compliance'
    end

    test '100% document and training compliance' do
      create(:assignment, :passed, employee_record: @employed, course: @course1)
      create(:assignment, :passed, employee_record: @employed, course: @course2)

      @employed.required_documents.each do |required_document_type|
        document = create(
          :document,
          document_type: required_document_type,
          file: file)

        create(
          :employee_document,
          employee_record: @employed,
          document: document
        )
      end

      sign_in_with(@employee_user)
      click_on 'Dashboard'

      refute_content '100% Overall Document Compliance'
      assert_content '100% Overall Training Compliance'
    end
  end

  private

  def file
    fixture_file_upload('test.pdf', 'application/pdf')
  end
end
