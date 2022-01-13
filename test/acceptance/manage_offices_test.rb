require 'test_helper'

class ManageOfficesTest < AcceptanceTestCase
  setup do
    @user = users(:account_manager)
    sign_in_with(@user)
    click_on 'Offices'
  end

  test 'listing' do
    tx_office = offices(:oceanview_tx)
    oh_office = offices(:oceanview_oh)

    assert_content tx_office.name
    assert_content oh_office.name
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
      document_group = create_office_document_group_for(@user.account)
      new_office = create(:office, account: @user.account, document_group: document_group)

      sign_in_with(user)
      click_on 'Offices'

      find("a[data-office-id=\"#{new_office.id}\"]").trigger('click')
      within '#delete-office-form' do
        click_button 'Delete'
      end

      assert_content 'Success'
    end
  end
end
