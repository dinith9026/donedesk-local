class TimeEntryForm < ApplicationForm
  attribute :employee_record_id, String
  attribute :entry_type, String
  attribute :occurred_at, String

  include CommonTimeEntryValidations

  def employee_record_full_name
    employee_record.full_name
  end

  def time_zone
    employee_record.office_time_zone
  end

  def formatted_occurred_at_in_time_zone
    return nil unless occurred_at.present?

    time_format = '%m/%d/%Y %-l:%M %p'

    if occurred_at.is_a?(String)
      Time.zone.parse(occurred_at).in_time_zone(time_zone).strftime(time_format)
    elsif occurred_at.is_a?(ActiveSupport::TimeWithZone)
      occurred_at.in_time_zone(time_zone).strftime(time_format)
    else
      nil
    end
  end

  def new_form_action
    employee_record_time_entries_path(context.employee_record)
  end

  def edit_form_action
    time_entry_path(id)
  end

  def employee_record
    context&.employee_record
  end

  def entry_type_changed?
    @entry_type_changed
  end

  def entry_type=(new_entry_type)
    @entry_type_changed =  new_entry_type != entry_type
    super(new_entry_type)
  end
end
