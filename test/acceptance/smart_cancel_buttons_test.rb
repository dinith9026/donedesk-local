require 'test_helper'

class SmartCancelButtonsTest < AcceptanceTestCase
  include ActionDispatch::TestProcess

  setup do
    Capybara.current_driver = :poltergeist

    @user = users(:account_owner)
    sign_in_with(@user)
  end

  teardown do
    Capybara.use_default_driver
  end

  test 'after initial sign in' do
    click_on 'New Course'
    within '#main-content' do
      click_on 'Cancel'
    end

    assert_equal root_path, current_path
    assert_content 'Document Compliance'
    assert_content 'Training Compliance'
  end

  describe 'after action other than index or show' do
    test 'returns user to index' do
      office = offices(:oceanview_tx)

      click_on 'Offices'
      edit_link_for(office).click
      fill_in 'office_name', with: ''
      click_on 'Save'
      within '#main-content' do
        click_on 'Cancel'
      end

      assert_equal offices_path, current_path
      assert_content 'All Offices'
    end

    test 'returns user to show' do
      office = offices(:oceanview_tx)

      click_on 'Offices'
      click_on office.name

      within find('#office-details') do
        click_on 'Edit', match: :first
      end

      fill_in 'office_name', with: ''
      click_on 'Save'
      within '#main-content' do
        click_on 'Cancel'
      end

      assert_equal office_path(office), current_path
      assert_content office.name.capitalize
    end
  end

  test 'after a JS-based action' do
    employee_record = employee_records(:ed)
    document = create(
      :document,
      document_type: document_types(:w4)
    )

    create(
      :employee_document,
      employee_record: employee_record,
      document: document
    )

    click_on 'Employees'
    click_on 'Employee Records'
    click_on 'Employee, Ed'
    click_on 'W-4'
    find('#doc-history-modal-close-btn').trigger('click') # Close modal
    within '#documents-section' do
      find_link('New Document').trigger('click')
    end
    click_on 'Cancel'

    assert_equal employee_record_path(employee_record), current_path
    assert_content employee_record.full_name
  end

  private

  def edit_link_for(office)
    find_link('Edit', href: /#{edit_office_path(office)}/i)
  end
end
