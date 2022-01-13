class TimeCard
  attr_reader :employee_record, :date

  delegate :full_name, to: :employee_record, prefix: true

  def initialize(employee_record, date)
    @employee_record = employee_record
    @date = date.in_time_zone(@employee_record.office_time_zone)
  end

  def regular_time
    return nil if has_missing_entries?

    total = 0

    clock_entries
      .each_slice(2) do |time_entry_pair|
         total += time_entry_pair.last.occurred_at - time_entry_pair.first.occurred_at
      end

    (total / 3600) - break_time
  end

  def break_time
    return nil if has_missing_entries?

    total = 0

    break_entries
      .each_slice(2) do |time_entry_pair|
         total += time_entry_pair.last.occurred_at - time_entry_pair.first.occurred_at
      end

    total / 3600
  end

  def pto_time
    @employee_record.pto_entries.find_by(date: @date)&.hours.presence || 0
  end

  def has_missing_entries?
    has_missing_break_entries? || has_missing_clock_entries?
  end

  def permitted_to?(entry_type)
    permitted_next_actions(most_recent_entry_type)
      .include?(entry_type.to_sym)
  end

  def valid_entry?(time_entry)
    permitted_next_actions(previous_entry(time_entry)&.entry_type)
      .include?(time_entry.entry_type.to_sym)
  end

  def time_entries
    @time_entries ||=
      @employee_record
      .time_entries
      .for_day(@date, @employee_record.office_time_zone)
      .order(:occurred_at)
  end

  def clocked_in?
    time_entries.any? && most_recent_entry_type != 'clock_out'
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

  def permitted_next_actions(previous_entry_type)
    case previous_entry_type.to_s.downcase
    when 'clock_in', 'end_break'
      [:clock_out, :start_break]
    when 'clock_out'
      [:clock_in]
    when 'start_break'
      [:end_break]
    else
      [:clock_in]
    end
  end

  def most_recent_entry_type
    time_entries&.last&.entry_type
  end

  def previous_entry(time_entry)
    where_clauses = []
    where_clauses << ['occurred_at < ?', time_entry.occurred_at]
    where_clauses << ['id != ?', time_entry.id] if time_entry.persisted?

    previous_entries = where_clauses.inject(time_entries) do |entries, clause_args|
      entries.send(:where, *clause_args)
    end

    previous_entries.order(:occurred_at).last
  end
end
