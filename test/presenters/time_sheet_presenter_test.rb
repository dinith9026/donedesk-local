require 'test_helper'

class TimeSheetPresenterTest < ActiveSupport::TestCase
  subject { TimeSheetPresenter.new(nil, nil) }
  should delegate_method(:employee_last_comma_first).to(:time_sheet)
  should delegate_method(:employee_title).to(:time_sheet)
  should delegate_method(:has_missing_entries?).to(:time_sheet)

  setup do
    @employee_record = employee_records(:ed)
    @date_range = 1.day.ago.to_date..Date.current
  end

  describe '#when_missing_entries' do
    test 'when true' do
      time_sheet = TimeSheet.new(@employee_record, @date_range)
      time_sheet.stubs(:has_missing_entries?).returns(true)
      subject = TimeSheetPresenter.new(time_sheet, nil)
      block_called = false

      subject.when_missing_entries { block_called = true }

      assert_equal true, block_called
    end

    test 'when false' do
      time_sheet = TimeSheet.new(@employee_record, @date_range)
      time_sheet.stubs(:has_missing_entries?).returns(false)
      subject = TimeSheetPresenter.new(time_sheet, nil)
      block_called = false

      subject.when_missing_entries { block_called = true }

      assert_equal false, block_called
    end
  end

  describe 'when_not_missing_entries' do
    test 'when true' do
      time_sheet = TimeSheet.new(@employee_record, @date_range)
      time_sheet.stubs(:has_missing_entries?).returns(false)
      subject = TimeSheetPresenter.new(time_sheet, nil)
      block_called = false

      subject.when_not_missing_entries { block_called = true }

      assert_equal true, block_called
    end

    test 'when false' do
      time_sheet = TimeSheet.new(@employee_record, @date_range)
      time_sheet.stubs(:has_missing_entries?).returns(true)
      subject = TimeSheetPresenter.new(time_sheet, nil)
      block_called = false

      subject.when_not_missing_entries { block_called = true }

      assert_equal false, block_called
    end
  end

  describe '#regular_time' do
    test 'when nil' do
      time_sheet = TimeSheet.new(@employee_record, @date_range)
      time_sheet.stubs(:regular_time).returns(nil)
      subject = TimeSheetPresenter.new(time_sheet, nil)

      assert_equal 'N/A', subject.regular_time
    end

    test 'when not nil' do
      time_sheet = TimeSheet.new(@employee_record, @date_range)
      time_sheet.stubs(:regular_time).returns(8.5)
      subject = TimeSheetPresenter.new(time_sheet, nil)

      assert_equal '8.5', subject.regular_time
    end
  end

  describe '#break_time' do
    test 'when nil' do
      time_sheet = TimeSheet.new(@employee_record, @date_range)
      time_sheet.stubs(:break_time).returns(nil)
      subject = TimeSheetPresenter.new(time_sheet, nil)

      assert_equal 'N/A', subject.break_time
    end

    test 'when not nil' do
      time_sheet = TimeSheet.new(@employee_record, @date_range)
      time_sheet.stubs(:break_time).returns(8.5)
      subject = TimeSheetPresenter.new(time_sheet, nil)

      assert_equal '8.5', subject.break_time
    end
  end

  # There are never missing entries for PTO time
  test '#pto_time' do
    time_sheet = TimeSheet.new(@employee_record, @date_range)
    time_sheet.stubs(:pto_time).returns(8.0)
    subject = TimeSheetPresenter.new(time_sheet, nil)

    assert_equal '8', subject.pto_time
  end

  test 'paths' do
    time_sheet = TimeSheet.new(@employee_record, @date_range)
    subject = TimeSheetPresenter.new(time_sheet, nil)

    refute_nil subject.time_card_path
  end
end
