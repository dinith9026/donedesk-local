require 'test_helper'

class TimeSheetTest < ActiveSupport::TestCase
  setup do
    date = Time.current
    @employee_record = employee_records(:ed)
    @date_range = date.beginning_of_day..date.end_of_day

    create(:pto_entry, employee_record: @employee_record, date: date)
  end

  describe '#initialize' do
    test 'when employee does not track time' do
      assert_raise TimeSheet::EmployeeDoesNotTrackTime do
        TimeSheet.new(employee_records(:eric), nil)
      end
    end
  end

  describe 'with entries missing' do
    setup do
      clock_in(@employee_record, '9:00 am')
      start_break(@employee_record, '11:00 am')

      @time_sheet = TimeSheet.new(@employee_record, @date_range)
    end

    test '#regular_time' do
      assert_nil @time_sheet.regular_time
    end

    test '#break_time' do
      assert_nil @time_sheet.break_time
    end

    test '#pto_time' do
      assert_equal 8, @time_sheet.pto_time
    end

    test '#has_missing_entries?' do
      assert_equal true, @time_sheet.has_missing_entries?
    end
  end

  describe 'with NO entries missing' do
    setup do
      clock_in(@employee_record, '8:00 am')
      start_break(@employee_record, '12:00 pm')
      end_break(@employee_record, '1:00 pm')
      clock_out(@employee_record, '5:00 pm')
      clock_in(@employee_record, '6:00 pm')
      clock_out(@employee_record, '7:00 pm')

      @time_sheet = TimeSheet.new(@employee_record, @date_range)
    end

    test '#regular_time' do
      assert_equal 9, @time_sheet.regular_time
    end

    test '#break_time' do
      assert_equal 1, @time_sheet.break_time
    end

    test '#pto_time' do
      assert_equal 8, @time_sheet.pto_time
    end

    test '#has_missing_entries?' do
      assert_equal false, @time_sheet.has_missing_entries?
    end
  end
end
