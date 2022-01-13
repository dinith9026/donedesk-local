require 'test_helper'

class TimeTrackingTest < AcceptanceTestCase
  setup do
    @employee_record = employee_records(:ed)

    Time.zone = @employee_record.office_time_zone

    clock_in(@employee_record, '8:30 AM')
    start_break(@employee_record, '12:00 PM')
    end_break(@employee_record, '1:00 PM')
    clock_out(@employee_record, '5:00 PM')

    create(:pto_entry, employee_record: @employee_record, hours: 4.5)

    @user = users(:account_manager)
  end

  teardown do
    TimeEntry.destroy_all
    PTOEntry.destroy_all
    Time.zone = 'UTC'
  end

  test 'managing time sheets, cards and entries' do
    sign_in_with @user

    click_on 'Time Sheets'

    fill_in_and_submit_date_range_filter_form(1.day.ago, Date.current)

    # view list of time sheets for an employee
    within '#time-sheets-table' do
      assert_content @employee_record.last_comma_first
      assert_content '7.5' # regular hours
      assert_content '1' # break hours
      assert_content '4.5' # pto hours

      click_on @employee_record.last_comma_first
    end

    # view list of time cards for an employee
    within time_cards_table_id do
      assert_time_card(Date.current, 7.5, 1, 4.5)

      click_on_time_card_link(Date.current)
    end

    tz_abbr = Time.zone.now.strftime('%Z')

    # view list of time entries for an employee's time card
    assert_content @employee_record.full_name
    assert_content 'Clock in'
    assert_content "08:30 AM #{tz_abbr}"
    assert_content 'Start break'
    assert_content "12:00 PM #{tz_abbr}"
    assert_content 'End break'
    assert_content "01:00 PM #{tz_abbr}"
    assert_content 'Clock out'
    assert_content "05:00 PM #{tz_abbr}"

    # test creating a time entry
    employee_name = @employee_record.last_comma_first
    valid_values = valid_time_entry_values
    invalid_values = valid_time_entry_values.merge(occurred_at: '')

    # with VALID params
    click_on 'Time Sheets'
    click_new_time_entry_btn_and_select_employee(employee_name)
    fill_in_and_submit_form_with(valid_values)
    assert_content 'Success'

    # with INVALID params
    click_new_time_entry_btn_and_select_employee(employee_name)
    fill_in_and_submit_form_with(invalid_values)
    assert_content 'Fix Errors'
    assert_content "Occurred at can't be blank"
  end

  private

  def valid_time_entry_values
    attributes_for(:time_entry)
  end

  def click_new_time_entry_btn_and_select_employee(employee_name)
    click_on 'New Time Entry'

    within '#new-time-entry-modal' do
      click_on @employee_record.last_comma_first
    end
  end

  def fill_in_and_submit_form_with(values)
    entry_type = values[:entry_type]&.humanize
    occurred_at = values[:occurred_at]&.to_date&.strftime('%m/%d/%Y')

    within '.new_time_entry' do
      select entry_type, from: 'time_entry_entry_type'
      fill_in 'time_entry_occurred_at', with: occurred_at
      click_on 'Save'
    end
  end
end
