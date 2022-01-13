class AssignedTrack < ApplicationRecord
  belongs_to :track
  belongs_to :employee_record
  has_many :courses, through: :track

  delegate :last_comma_first, to: :employee_record, prefix: true
  delegate :name, :active?, :courses, :deactivated?, to: :track, prefix: true
  delegate :account_id, :passed_assignments_for, :total_active_courses, to: :track

  scope :for_employed_employees, -> (ids) do
    where(employee_record_id: ids).joins(:employee_record).merge(EmployeeRecord.employed)
  end

  def progress
    (passed_assignments_for(employee_record_id).count.to_f / total_active_courses.to_f) * 100
  end
end
