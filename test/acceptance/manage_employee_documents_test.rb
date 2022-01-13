require 'test_helper'

class ManageEmployeeDocumentsTest < AcceptanceTestCase
  setup do
    @user = users(:account_manager)

    Time.zone = @user.time_zone

    sign_in_with(@user)
    navigate_to('Documents > All Documents')
  end

  teardown do
    Time.zone = 'UTC'
  end

  test 'listing' do
    employee_document = employee_documents(:oceanview_ed_w4)

    assert_content employee_document.document_name
    assert_content employee_document.employee_record_full_name
    assert_content employee_document.created_at.strftime('%m/%d/%Y')
  end

  describe 'create' do
    test 'with invalid params' do
      click_on 'New Employee Document'
      within '#new-employee-document-modal' do
        click_on employee_records(:ed).last_comma_first
      end

      click_button 'Save'

      assert_content 'Please fix the errors below!'
    end

    test 'with valid params' do
      document_type = document_types(:w4)
      new_document = build(:document)

      click_on 'New Employee Document'
      within '#new-employee-document-modal' do
        click_on employee_records(:ed).last_comma_first
      end

      select document_type.name, from: 'document_document_type_id'
      fill_in 'document_summary', with: new_document.summary
      page.attach_file('document_file', Rails.root + 'test/fixtures/test.pdf')
      fill_in 'document_expires_on', with: 1.year.from_now.to_s(:default)
      click_button 'Save'

      assert_content 'Success'
      assert_content document_type.name
    end
  end

  test 'update' do
    employee_document = employee_documents(:oceanview_ed_w4)
    new_summary = 'A new summary'

    find("a[href=\"#{edit_employee_document_path(employee_document)}\"]").click

    fill_in 'document_summary', with: new_summary
    click_button 'Save'

    assert_content 'Success'
    assert_content employee_document.document_name
    assert_content new_summary
  end

  describe 'delete' do
    setup do
      Capybara.current_driver = :poltergeist
    end

    teardown do
      Capybara.use_default_driver
    end

    test 'success' do
      user = users(:account_manager)
      document = documents(:oceanview_ed_w4)

      sign_in_with(user)
      navigate_to('Documents > All Documents')

      find("a[data-document-id=\"#{document.id}\"]").trigger('click')
      within '#delete-document-form' do
        click_button 'Delete'
      end

      assert_content 'Success'
    end
  end
end
