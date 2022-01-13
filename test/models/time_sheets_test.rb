require 'test_helper'

class TimeSheetsTest < ActiveSupport::TestCase
  setup do
    @ed = employee_records(:ed)
    @mary = employee_records(:mary)

    clock_in(@ed, '8:00 am')
    start_break(@ed, '12:00 pm')
    end_break(@ed, '1:00 pm')
    clock_out(@ed, '5:00 pm')

    clock_in(@mary, '8:00 am')
    start_break(@mary, '12:00 pm')
    end_break(@mary, '1:00 pm')
    clock_out(@mary, '5:00 pm')

    create(:pto_entry, employee_record: @ed, hours: 8, date: Date.current)
    create(:pto_entry, employee_record: @mary, hours: 8, date: Date.current)

    employee_records = [@ed, @mary]
    @date_range = Time.current.beginning_of_day..Time.current.end_of_day

    @time_sheets = TimeSheets.new(employee_records, @date_range)
  end

  teardown { TimeEntry.destroy_all }

  test '#each' do
    assert_respond_to @time_sheets, :each
  end

  test '#total_regular_hours' do
    assert_equal 16, @time_sheets.total_regular_hours
  end

  test '#total_break_hours' do
    assert_equal 2, @time_sheets.total_break_hours
  end

  test '#total_pto_hours' do
    assert_equal 16, @time_sheets.total_pto_hours
  end
end
