class TimeEntry < ApplicationRecord
  attribute :occurred_at, :datetime, default: -> { DateTime.current }

  belongs_to :employee_record

  enum entry_type: { clock_in: 0, clock_out: 1, start_break: 2, end_break: 3 }

  delegate :account_id, :office_time_zone, to: :employee_record
  delegate :full_name, to: :employee_record, prefix: true

  include CommonTimeEntryValidations

  validates :employee_record, presence: true

  scope :for_day, -> (date, time_zone) do
    Time.use_zone(time_zone) do
      where(occurred_at: date.to_date.beginning_of_day..date.to_date.end_of_day)
        .order(:occurred_at)
    end
  end

  scope :within, -> (date_range, time_zone) do
    Time.use_zone(time_zone) do
      where(occurred_at: date_range).order(:occurred_at)
    end
  end

  def occurred_at_in_zone
    occurred_at.in_time_zone(office_time_zone)
  end
end
