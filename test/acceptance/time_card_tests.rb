require 'test_helper'

module TimeCardTests
  extend ActiveSupport::Concern

  included do
    setup do
      Capybara.current_driver = :poltergeist
      sign_in_with @user
    end

    teardown do
      Capybara.use_default_driver
      @user.employee_record.time_entries.destroy_all
    end

    test 'clocking in, starting break, ending break, clocking out' do
      click_on_time_card_link

      within '#time-entry-modal' do
        click_on 'Clock In'
      end

      assert_content 'Success!'

      click_on_time_card_link

      within '#time-entry-modal' do
        assert page.has_button?('Clock In', disabled: true)
        assert page.has_button?('Start Break', disabled: false)
        assert page.has_button?('End Break', disabled: true)
        assert page.has_button?('Clock Out', disabled: false)
        click_on 'Start Break'
      end

      assert_content 'Success!'

      click_on_time_card_link

      within '#time-entry-modal' do
        assert page.has_button?('Clock In', disabled: true)
        assert page.has_button?('Start Break', disabled: true)
        assert page.has_button?('End Break', disabled: false)
        assert page.has_button?('Clock Out', disabled: true)
        click_on 'End Break'
      end

      assert_content 'Success!'

      click_on_time_card_link

      within '#time-entry-modal' do
        assert page.has_button?('Clock In', disabled: true)
        assert page.has_button?('Start Break', disabled: false)
        assert page.has_button?('End Break', disabled: true)
        assert page.has_button?('Clock Out', disabled: false)
        click_on 'Clock Out'
      end

      assert_content 'Success!'

      click_on_time_card_link

      within '#time-entry-modal' do
        assert page.has_button?('Clock In', disabled: false)
        assert page.has_button?('Start Break', disabled: true)
        assert page.has_button?('End Break', disabled: true)
        assert page.has_button?('Clock Out', disabled: true)
      end
    end

    def click_on_time_card_link
      find("a[href=\"#time-entry-modal\"]").trigger('click')
    end
  end
end
