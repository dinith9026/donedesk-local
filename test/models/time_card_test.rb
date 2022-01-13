require 'test_helper'

class TimeCardTest < ActiveSupport::TestCase
  setup do
    @employee_record = employee_records(:ed)
    @time_card = TimeCard.new(@employee_record, Date.current)
    create(:pto_entry, employee_record: @employee_record, date: Date.current)
  end

  teardown { TimeEntry.destroy_all }

  describe 'with entries missing' do
    setup do
      clock_in(@employee_record, '9:00 am')
      start_break(@employee_record, '11:00 am')
    end

    test '#regular_time' do
      assert_nil @time_card.regular_time
    end

    test '#break_time' do
      assert_nil @time_card.break_time
    end

    test '#pto_time' do
      assert_equal 8, @time_card.pto_time
    end

    test '#has_missing_entries?' do
      assert_equal true, @time_card.has_missing_entries?
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
    end

    test '#regular_time' do
      assert_equal 9, @time_card.regular_time
    end

    test '#break_time' do
      assert_equal 1, @time_card.break_time
    end

    test '#pto_time' do
      assert_equal 8, @time_card.pto_time
    end

    test '#has_missing_entries?' do
      assert_equal false, @time_card.has_missing_entries?
    end
  end

  describe '#permitted_to?' do
    describe 'when attempting to clock in' do
      test 'not allowed when last time entry for the current day is a clock in' do
        clock_in(@employee_record, '9:00 AM')
        assert_equal false, @time_card.permitted_to?('clock_in')
      end

      test 'allowed when last time entry is from previous day' do
        clock_in(@employee_record, 1.day.ago)
        assert_equal true, @time_card.permitted_to?('clock_in')
      end

      test 'allowed when last time entry for the current day is a clock out' do
        clock_in(@employee_record)
        clock_out(@employee_record)
        assert_equal true, @time_card.permitted_to?('clock_in')
      end
    end

    describe 'when attempting to clock out' do
      test 'not allowed when last time entry for the current day is a clock out' do
        clock_in(@employee_record)
        clock_out(@employee_record)
        assert_equal false, @time_card.permitted_to?('clock_out')
      end

      test 'not allowed when last time entry for the current day is a start break' do
        clock_in(@employee_record)
        start_break(@employee_record)
        assert_equal false, @time_card.permitted_to?('clock_out')
      end

      test 'allowed when last time entry for the current day is a end break' do
        clock_in(@employee_record, '9:00 AM')
        start_break(@employee_record, '12:00 PM')
        end_break(@employee_record, '1:00 PM')
        assert_equal true, @time_card.permitted_to?('clock_out')
      end

      test 'allowed when last time entry for the current day is a clock in' do
        clock_in(@employee_record, '9:00 AM')
        assert_equal true, @time_card.permitted_to?('clock_out')
      end
    end

    describe 'when attempting to start break' do
      test 'not allowed when last time entry for the current day is a start break' do
        clock_in(@employee_record)
        start_break(@employee_record)
        assert_equal false, @time_card.permitted_to?('start_break')
      end

      test 'not allowed when last time entry for the current day is a clock out' do
        clock_in(@employee_record)
        clock_out(@employee_record)
        assert_equal false, @time_card.permitted_to?('start_break')
      end

      test 'allowed when last time entry for the current day is a clock in' do
        clock_in(@employee_record, '9:00 AM')
        assert_equal true, @time_card.permitted_to?('start_break')
      end

      test 'allowed when last time entry for the current day is a end break' do
        clock_in(@employee_record, '9:00 AM')
        start_break(@employee_record, '12:00 PM')
        end_break(@employee_record, '1:00 PM')
        assert_equal true, @time_card.permitted_to?('start_break')
      end
    end

    describe 'when attempting to end break' do
      test 'not allowed when last time entry for the current day is an end break' do
        clock_in(@employee_record)
        start_break(@employee_record)
        end_break(@employee_record)
        assert_equal false, @time_card.permitted_to?('end_break')
      end

      test 'not allowed when last time entry for the current day is a clock in' do
        clock_in(@employee_record)
        assert_equal false, @time_card.permitted_to?('end_break')
      end

      test 'not allowed when last time entry for the current day is a clock out' do
        clock_in(@employee_record)
        clock_out(@employee_record)
        assert_equal false, @time_card.permitted_to?('end_break')
      end

      test 'allowed when last time entry for the current day is a start break' do
        clock_in(@employee_record, '9:00 AM')
        start_break(@employee_record, '12:00 PM')
        assert_equal true, @time_card.permitted_to?('end_break')
      end
    end
  end

  describe '#clocked_in?' do
    test 'when no entries exist' do
      assert_equal false, @time_card.clocked_in?
    end

    test 'when entries exist and last entry is a clock out' do
      clock_in(@employee_record)
      clock_out(@employee_record)
      assert_equal false, @time_card.clocked_in?
    end

    test 'when entries exist and last entry is NOT a clock out' do
      clock_in(@employee_record, '9:00 AM')
      assert_equal true, @time_card.clocked_in?
    end
  end

  describe '#valid_entry?' do
    test 'when attempting to add a new valid entry when no other entries exist' do
      new_entry = build(:time_entry, :clock_in, occurred_at: '9:00 AM')

      assert_equal true, @time_card.valid_entry?(new_entry)
    end

    test 'when attempting to add a new entry with an invalid entry type' do
      clock_in(@employee_record, '9:00 AM')
      clock_out(@employee_record, '5:00 PM')

      new_entry = build(:time_entry, :end_break, occurred_at: '12:00 PM')

      assert_equal false, @time_card.valid_entry?(new_entry)
    end

    test 'when attempting to update an valid existing entry with invalid entry type' do
      clock_in(@employee_record, '9:00 AM')
      existing_entry = clock_out(@employee_record, '5:00 PM')

      existing_entry.entry_type = 'end_break'

      assert_equal false, @time_card.valid_entry?(existing_entry)
    end

    test 'when attempting to add a new entry with a valid entry type' do
      clock_in(@employee_record, '9:00 AM')
      clock_out(@employee_record, '5:00 PM')

      new_entry = build(:time_entry, :start_break, occurred_at: '12:00 PM')

      assert_equal true, @time_card.valid_entry?(new_entry)
    end

    test 'when attempting to update an existing entry with a new occurred_at time' do
      clock_in(@employee_record, '9:00 AM')
      existing_entry = clock_out(@employee_record, '5:00 PM')

      existing_entry.occurred_at = '6:00 PM'

      assert_equal true, @time_card.valid_entry?(existing_entry)
    end

    test 'when attempting to create a new entry on the UTC cutoff for time zone' do
      clock_in(@employee_record, '9:00 AM CST')

      # 6:00 PM CST is midnight the next day in UTC
      params = { entry_type: 'clock_out', occurred_at: '6:00 PM CST' }
      time_entry = @employee_record.time_entries.build(params)

      time_card = TimeCard.new(@employee_record, time_entry.occurred_at)

      assert time_card.valid_entry?(time_entry)
    end
  end
end
