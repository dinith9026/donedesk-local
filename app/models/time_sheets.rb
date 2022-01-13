class TimeSheets
  include Enumerable

  attr_reader :date_range

  def initialize(employee_records, date_range)
    @employee_records = employee_records
    @date_range = date_range
  end

  def each(&block)
    time_sheets.each { |time_sheet| yield(time_sheet) }
  end

  def include?(time_sheet)
    time_sheets.find { |ts| ts.employee_record.id == time_sheet.employee_record.id }
  end

  def total_regular_hours
    time_sheets_with_no_missing_entries
      .map(&:regular_time)
      .inject(0, &:+)
  end

  def total_break_hours
    time_sheets_with_no_missing_entries
      .map(&:break_time)
      .inject(0, &:+)
  end

  def total_pto_hours
    time_sheets_with_no_missing_entries
      .map(&:pto_time)
      .inject(0, &:+)
  end

  private

  def time_sheets_with_no_missing_entries
    @time_sheets_with_no_missing_entries ||=
      time_sheets.reject(&:has_missing_entries?)
  end

  def time_sheets
    @time_sheets ||=
      @employee_records.map do |employee_record|
        TimeSheet.new(employee_record, @date_range)
      end
  end
end
