class TimeEntryPresenter < ModelPresenter
  presents :time_entry
  delegate :employee_record_full_name, to: :time_entry

  def entry_type
    time_entry.entry_type.humanize
  end

  def occurred_at
    time_entry.occurred_at.strftime("%I:%M %p")
  end

  def occurred_at_in_zone
    time_entry.occurred_at_in_zone.strftime("%I:%M %p %Z")
  end
end
