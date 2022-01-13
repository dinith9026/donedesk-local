class TimeCardPresenter < ModelPresenter
  presents :time_card

  DEFAULT_DATE_FORMAT = '%a, %b %-e, %Y'

  delegate :employee_record_full_name, to: :time_card

  def icon_class
    if time_card.clocked_in?
      'black'
    else
      ''
    end
  end

  def when_has_entries(&block)
    yield if time_entries.any?
  end

  def last_entry_time_and_type
    "#{last_entry.occurred_at} - #{last_entry.entry_type}"
  end

  def when_missing_entries(&block)
    yield if time_card.has_missing_entries?
  end

  def when_not_missing_entries(&block)
    yield unless time_card.has_missing_entries?
  end

  def regular_time
    format_hours(time_card.regular_time)
  end

  def break_time
    format_hours(time_card.break_time)
  end

  def pto_time
    format_hours(time_card.pto_time)
  end

  def disable_button_for?(entry_type)
    !time_card.permitted_to?(entry_type)
  end

  def entry_types
    TimeEntry.entry_types.keys
  end

  def time_entries
    time_card.time_entries.map do |time_entry|
      presenter_for(time_entry)
    end
  end

  def modal_title
    Time.current.strftime('%A - %b %e, %Y')
  end

  def date
    time_card.date.strftime(DEFAULT_DATE_FORMAT)
  end

  def time_entries_path
    employee_record_time_entries_path(
      time_card.employee_record,
      date: time_card.date.to_date
    )
  end

  private

  def format_hours(hours)
    '%g' % ('%.2f' % hours)
  end

  def last_entry
    time_entries.last
  end
end
