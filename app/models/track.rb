class Track < ApplicationRecord
  include Deactivateable

  belongs_to :account
  has_many :courses_tracks, -> { order(position: :asc) }
  has_many :courses, through: :courses_tracks
  has_many :assigned_tracks
  has_many :employee_records, through: :assigned_tracks

  validates :name, :courses, presence: true
  validates :name, uniqueness: { scope: :account_id,
                                 case_sensitive: false,
                                 allow_blank: true }

  def assigned_tracks_for_employed_employees
    employee_record_ids = assigned_tracks.map(&:employee_record_id)

    assigned_tracks.for_employed_employees(employee_record_ids)
  end

  def completed?(employee_record_id)
    assignments = assignments_for(employee_record_id)
    passed_assignments = assignments.select(&:passed?)

    passed_assignments.length >= courses.active.length
  end

  def next_course_to_take(employee_record_id)
    assignments = assignments_for(employee_record_id)

    find_first_course_without_passed_assignment(assignments)
  end

  def total_active_courses
    courses.active.count
  end

  def employed_employee_records
    employee_records.employed
  end

  def unassigned_employees
    EmployeeRecord
      .joins("LEFT JOIN assigned_tracks " \
             "ON assigned_tracks.employee_record_id = employee_records.id " \
             "AND assigned_tracks.track_id = #{quote(id)}")
      .where("assigned_tracks.employee_record_id IS NULL")
      .joins(:office, :account)
      .where(accounts: { id: account_id })
      .active
  end

  def passed_assignments_for(employee_record_id)
    active_assignments_for(employee_record_id).select(&:passed?)
  end

  private

  def quote(value)
    ActiveRecord::Base.connection.quote(value)
  end

  def active_assignments_for(employee_record_id)
    Assignment
      .where(employee_record_id: employee_record_id, course_id: active_course_ids)
      .includes([:exams, :course])
  end

  def active_course_ids
    courses.active.map(&:id)
  end

  def assignments_for(employee_record_id)
    Assignment.where(
      employee_record_id: employee_record_id,
      course_id: courses.active.pluck(:id)
    )
  end

  # By default, courses are ordered by their position, so the first course with
  # no passing assignment is the next course to take.
  def find_first_course_without_passed_assignment(assignments)
    courses.active.find do |course|
      assignments.find { |a| a.course_id == course.id && !a.passed?}
    end
  end
end
