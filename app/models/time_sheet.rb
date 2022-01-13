class TimeSheet
  class EmployeeDoesNotTrackTime < StandardError; end

  attr_reader :employee_record, :date_range

  def initialize(employee_record, date_range)
    raise EmployeeDoesNotTrackTime unless employee_record.tracks_time?

    @employee_record = employee_record
    @date_range = date_range
  end

  def ==(other_time_sheet)
    @employee_record.id == other_time_sheet.employee_record.id
  end

  def employee_last_comma_first
    @employee_record.last_comma_first
  end

  def employee_title
    @employee_record.title
  end

  def regular_time
    return nil if has_missing_entries?

    total_hours = sum_hours_for_entry_types(:clock_in, :clock_out)

    total_hours - break_time
  end

  def break_time
    return nil if has_missing_entries?

    total_hours = sum_hours_for_entry_types(:start_break, :end_break)

    total_hours
  end

  def pto_time
    @employee_record.pto_entries.within(@date_range).sum(:hours)
  end

  def has_missing_entries?
    has_missing_break_entries? || has_missing_clock_entries?
  end

  private

  def has_missing_break_entries?
    break_entries.count.odd?
  end

  def has_missing_clock_entries?
    clock_entries.count.odd?
  end

  def clock_entries
    @clock_entries ||=
      time_entries
      .select { |time_entry| time_entry.clock_in? || time_entry.clock_out? }
  end

  def break_entries
    @break_entries ||=
      time_entries
      .select { |time_entry| time_entry.start_break? || time_entry.end_break? }
  end

  def time_entries
    @time_entries ||=
      @employee_record
      .time_entries
      .within(@date_range, @employee_record.office_time_zone)
  end

  def time_entries_grouped_by_day
    @time_entries_grouped_by_day ||=
      time_entries.group_by { |time_entry| time_entry.occurred_at_in_zone.to_date }
  end

  def sum_hours_for_entry_types(start_type, end_type)
    daily_totals = []

    time_entries_grouped_by_day.each_with_index do |(_date, time_entries), index|
      daily_totals[index] = 0

      time_entries
        .select do |time_entry|
          time_entry.public_send("#{start_type}?") ||
            time_entry.public_send("#{end_type}?")
        end
        .each_slice(2) do |time_entry_pair|
          daily_totals[index] +=
            time_entry_pair.last.occurred_at - time_entry_pair.first.occurred_at
        end
    end

    daily_totals.compact.sum / 3600
  end
end
