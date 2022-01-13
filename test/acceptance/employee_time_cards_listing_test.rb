require 'test_helper'

class EmployeeTimeCardsListingTest < AcceptanceTestCase
  setup do
    @user = users(:employee)
    @employee_record = @user.employee_record

    Time.zone = @employee_record.office_time_zone

    clock_in(@employee_record, '8:00 am')
    start_break(@employee_record, '12:00 pm')
    end_break(@employee_record, '1:00 pm')
    clock_out(@employee_record, '5:00 pm')

    create(:pto_entry, employee_record: @employee_record, hours: 6)
  end

  teardown do
    TimeEntry.destroy_all
    Time.zone = 'UTC'
  end

  test 'listing' do
    sign_in_with(@user)

    click_on 'Time Cards'

    fill_in_and_submit_date_range_filter_form(1.day.ago, Date.current)

    within time_cards_table_id do
      assert_time_card(Date.current, 8, 1, 6)

      click_on_time_card_link(Date.current)
    end

    tz_abbr = Time.zone.now.strftime('%Z')

    within '#time-entries-table' do
      assert_content @employee_record.full_name
      assert_content 'Clock in'
      assert_content "08:00 AM #{tz_abbr}"
      assert_content 'Start break'
      assert_content "12:00 PM #{tz_abbr}"
      assert_content 'End break'
      assert_content "01:00 PM #{tz_abbr}"
      assert_content 'Clock out'
      assert_content "05:00 PM #{tz_abbr}"
    end
  end
end
