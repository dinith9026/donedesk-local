class TimeSheetPresenter < ModelPresenter
  presents :time_sheet

  delegate :employee_last_comma_first, :employee_title, :has_missing_entries?,
    to: :time_sheet

  def when_missing_entries(&block)
    yield if has_missing_entries?
  end

  def when_not_missing_entries(&block)
    yield unless has_missing_entries?
  end

  def regular_time
    format_hours(time_sheet.regular_time)
  end

  def break_time
    format_hours(time_sheet.break_time)
  end

  def pto_time
    format_hours(time_sheet.pto_time)
  end

  def time_card_path
    employee_record_time_cards_path(
      time_sheet.employee_record,
      date_from: time_sheet.date_range.begin.to_date,
      date_to: time_sheet.date_range.end.to_date
    )
  end

  private

  def format_hours(hours)
    return 'N/A' if hours.nil?

    '%g' % ('%.2f' % hours)
  end
end
