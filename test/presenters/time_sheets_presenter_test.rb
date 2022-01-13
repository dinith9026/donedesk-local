require 'test_helper'

class TimeSheetsPresenterTest < ActiveSupport::TestCase
  test '#initialize' do
    time_sheets = [
      TimeSheet.new(employee_records(:ed), nil),
      TimeSheet.new(employee_records(:mary), nil)
    ]
    presenter = TimeSheetsPresenter.new(time_sheets, nil)

    assert_equal 2, presenter.count
    assert_respond_to presenter, :each
  end

  test '#active_employee_records_who_track_time' do
    account = accounts(:oceanview_dental)
    office_with_time_tracking = offices(:oceanview_tx)
    office_without_time_tracking = offices(:oceanview_oh)
    subject =
      TimeSheetsPresenter
      .new([], nil)
      .with_context(current_account: account)

    result = subject.active_employee_records_who_track_time

    assert_includes result, office_with_time_tracking.employee_records.first
    refute_includes result, office_without_time_tracking.employee_records.first
  end

  test '#time_tracking_offices' do
    account = accounts(:oceanview_dental)
    office_with_time_tracking = offices(:oceanview_tx)
    office_without_time_tracking = offices(:oceanview_oh)
    subject =
      TimeSheetsPresenter
      .new([], nil)
      .with_context(current_account: account)

    result = subject.time_tracking_offices

    assert_includes result, office_with_time_tracking
    refute_includes result, office_without_time_tracking
  end

  describe '#total_regular_hours' do
    test 'when total hours is NOT a float' do
      time_sheets = TimeSheets.new(nil, nil)
      time_sheets.stubs(:total_regular_hours).returns(8)
      presenter = TimeSheetsPresenter.new(time_sheets, nil)

      assert_equal '8', presenter.total_regular_hours
    end

    test 'when total hours is a float' do
      time_sheets = TimeSheets.new(nil, nil)
      time_sheets.stubs(:total_regular_hours).returns(8.5)
      presenter = TimeSheetsPresenter.new(time_sheets, nil)

      assert_equal '8.5', presenter.total_regular_hours
    end
  end

  describe '#total_break_hours' do
    test 'when total hours is NOT a float' do
      time_sheets = TimeSheets.new(nil, nil)
      time_sheets.stubs(:total_break_hours).returns(1)
      presenter = TimeSheetsPresenter.new(time_sheets, nil)

      assert_equal '1', presenter.total_break_hours
    end

    test 'when total hours is a float' do
      time_sheets = TimeSheets.new(nil, nil)
      time_sheets.stubs(:total_break_hours).returns(0.5)
      presenter = TimeSheetsPresenter.new(time_sheets, nil)

      assert_equal '0.5', presenter.total_break_hours
    end
  end

  describe '#total_pto_hours' do
    test 'when total hours is NOT a float' do
      time_sheets = TimeSheets.new(nil, nil)
      time_sheets.stubs(:total_pto_hours).returns(8)
      presenter = TimeSheetsPresenter.new(time_sheets, nil)

      assert_equal '8', presenter.total_pto_hours
    end

    test 'when total hours is a float' do
      time_sheets = TimeSheets.new(nil, nil)
      time_sheets.stubs(:total_pto_hours).returns(0.5)
      presenter = TimeSheetsPresenter.new(time_sheets, nil)

      assert_equal '0.5', presenter.total_pto_hours
    end
  end

  describe 'with date_range context' do
    setup do
      time_sheets = TimeSheets.new(nil, nil)
      date_range = '2018-08-06'..'2018-08-12'

      @presenter =
        TimeSheetsPresenter
        .new(time_sheets, nil)
        .with_context(date_range: date_range)
    end

    describe '#date_from' do
      test 'with default format' do
        assert_equal 'Mon, Aug 6, 2018', @presenter.date_from
      end

      test 'with custom format' do
        assert_equal '08/06/2018', @presenter.date_from('%m/%d/%Y')
      end
    end

    describe '#date_to' do
      test 'with default format' do
        assert_equal 'Sun, Aug 12, 2018', @presenter.date_to
      end

      test 'with custom format' do
        assert_equal '08/12/2018', @presenter.date_to('%m/%d/%Y')
      end
    end
  end

  test '#to_csv' do
    ed = employee_records(:ed)
    mary = employee_records(:mary)
    time_sheet_for_ed = TimeSheet.new(ed, nil)
    time_sheet_for_mary = TimeSheet.new(mary, nil)
    time_sheets = [time_sheet_for_ed, time_sheet_for_mary]
    presenter = TimeSheetsPresenter.new(time_sheets, nil)
    expected_csv = <<~CSV
    employee,hours,break,pto
    \"Employee, Ed\",0,0,0
    \"Manager, Mary\",0,0,0
    CSV

    result = presenter.to_csv

    assert_equal expected_csv, result
  end

  test '#csv_filename' do
    date_from = '2018-08-06'
    date_to = '2018-08-12'
    presenter =
      TimeSheetsPresenter
      .new([], nil)
      .with_context(date_range: date_from..date_to)
    expected_filename = "time-sheets-#{date_from}-to-#{date_to}.csv"

    result = presenter.csv_filename

    assert_equal expected_filename, result
  end
end
