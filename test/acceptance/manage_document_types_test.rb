require 'test_helper'

class ManageDocumentTypesTest < AcceptanceTestCase
  setup do
    @user = users(:account_manager)
    @canned_document_type = document_types(:w4)
    @custom_document_type = document_types(:oceanview_performance_review)
    sign_in_with(@user)
    navigate_to('Employees > Document Types')
  end

  test 'listing' do
    assert_content @canned_document_type.name
    assert_content @custom_document_type.name
  end

  test 'create' do
    values = valid_document_type_values

    click_on 'New Type'

    fill_in_and_submit_form_with(values)

    assert_document_type values
  end

  test 'update' do
    new_values = { name: 'New Name' }

    find("a[href='#{edit_document_type_path(@custom_document_type)}']").click

    fill_in_and_submit_form_with(new_values)

    assert_document_type new_values
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
      new_type = create(:document_type, account: user.account)

      sign_in_with(user)
      navigate_to('Documents > Document Types')

      find("a[data-document-type-id=\"#{new_type.id}\"]").trigger('click')
      within '#delete-document-type-form' do
        click_button 'Delete'
      end

      assert_content 'Success'
    end
  end

  private

  def valid_document_type_values
    attributes_for(:document_type)
  end

  def fill_in_and_submit_form_with(values)
    fill_in 'document_type_name', with: values[:name]
    select 'Employees', from: 'document_type_applies_to'
    click_button 'Save'
  end

  def assert_document_type(values)
    assert_content values[:name]
    assert_content values[:required?]
  end
end
