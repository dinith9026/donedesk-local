require 'csv'

class TimeSheetsPresenter < CollectionPresenter
  DEFAULT_DATE_FORMAT = '%a, %b %-e, %Y'

  def active_employee_records_who_track_time
    employee_records = context.current_account.employee_records.active.tracks_time
    EmployeeRecordsPresenter.new(employee_records, current_user)
  end

  def time_tracking_offices
    context.current_account.offices.tracks_time
  end

  def total_regular_hours
    format_hours(@collection.total_regular_hours)
  end

  def total_break_hours
    format_hours(@collection.total_break_hours)
  end

  def total_pto_hours
    format_hours(@collection.total_pto_hours)
  end

  def date_from(format = DEFAULT_DATE_FORMAT)
    context&.date_range.begin.to_date.strftime(format)
  end

  def date_to(format = DEFAULT_DATE_FORMAT)
    context&.date_range.end.to_date.strftime(format)
  end

  def to_csv
    attributes = %w{employee hours break pto}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      each do |time_sheet_presenter|
        csv << [
          time_sheet_presenter.employee_last_comma_first,
          time_sheet_presenter.regular_time,
          time_sheet_presenter.break_time,
          time_sheet_presenter.pto_time,
        ]
      end
    end
  end

  def csv_filename
    "time-sheets-#{date_from('%Y-%m-%d')}-to-#{date_to('%Y-%m-%d')}.csv"
  end

  private

  def format_hours(hours)
    '%g' % ('%.2f' % hours)
  end
end
