class Assignment < ApplicationRecord
  EXPIRING_SOON_THRESHOLD = 45 # days

  class NotExpirable < StandardError
    def initialize(method)
      super("Calling `##{method}` when no expiration exists is not allowed. Use `#expirable?`.")
    end
  end

  belongs_to :course
  belongs_to :employee_record
  has_one :account, through: :employee_record
  has_many :exams, dependent: :destroy
  has_many :courses_tracks, through: :course

  delegate :title, :description, :material_url, :material_s3_key, :material_type,
           :active?, :questions, :passing_threshold_percentage, :max_test_retakes,
           :supplements,
             to: :course, prefix: true
  delegate :user_email, :id, :first_name, :full_name, :last_comma_first, :first_initial_and_last, :office_name,
             to: :employee_record, prefix: true
  delegate :user, to: :employee_record

  validate :course_has_at_least_one_question

  scope :for_employed_employees, -> (ids) { where(employee_record_id: ids).joins(:employee_record).merge(EmployeeRecord.employed) }
  scope :active, -> { joins(:course).merge(Course.active).joins(:employee_record).merge(EmployeeRecord.employed) }

  def due_date
    if expirable? && (passed? || expired?)
      expires_on
    elsif !passed? && course.days_due_within
      created_at.to_date + course.days_due_within
    else
      nil
    end
  end

  def days_until_due
    if due_date
      (due_date - Date.current).to_i
    else
      nil
    end
  end

  def course_belongs_to_track?
    courses_tracks.any?
  end

  def course_belongs_to_assigned_track?
    tracks_course_belongs_to = courses_tracks.map(&:track_id)
    tracks_employee_assigned_to = employee_record.assigned_tracks.map(&:track_id)

    (tracks_course_belongs_to & tracks_employee_assigned_to).any?
  end

  def active_tracks
    courses_tracks
    .includes(:track)
    .where(track_id: employee_record.assigned_tracks.pluck(:track_id))
    .map(&:track)
    .select(&:active?)
  end

  def create_certificate!(passed_on = Date.current)
    Certificate.create!(
      course: course,
      employee_record: employee_record,
      passed_on: passed_on,
      expires_on: expirable? ? passed_on + course.compliance_expiration_in_days_value.to_f.days : nil
    )
  end

  def active?
    course.active? && employee_record.employed?
  end

  def action(maybe_track)
    AssignmentAction.from_assignment(self, maybe_track)
  end

  def exam_takeable?
    ['new', 'expired', 'failed'].include?(state) || expiring_soon?
  end

  def certificate_obtainable?
    passed? || expired?
  end

  def exam_retakes_remaining
    @exam_retakes_remaining ||=
      ExamRetakesRemaining
      .new(course_max_test_retakes, exams.size)
      .calculate
  end

  def exam_retakes_remaining?
    exam_retakes_remaining > 0
  end

  def state
    if exams.none?
      'new'
    elsif passed?
      'passed'
    elsif expired?
      'expired'
    else
      'failed'
    end
  end

  def new?
    'new' == state
  end

  def passed?
    exams.any? { |exam| exam.passed } && !expired?
  end

  def date_passed
    passed_exam.created_at.to_date
  end

  def passed_exam
    exams.sort_by(&:created_at).reverse.find { |exam| exam.passed }
  end

  def failed?
    exams.any? && exams.none? { |exam| exam.passed }
  end

  def expirable?
    course.has_expiration?
  end

  def expires_on
    raise NotExpirable.new(__method__.to_s) if !expirable?

    (course.compliance_expiration_in_days_value - days_since_exam_passed).days.from_now.to_date
  end

  def expired?
    return false if !expirable? || passed_exam.nil?

    days_since_exam_passed >= course.compliance_expiration_in_days_value
  end

  def expiring_soon?
    return false if !expirable? || expired? || passed_exam.nil?

    days_expires_in <= EXPIRING_SOON_THRESHOLD
  end

  def days_expires_in
    (course.compliance_expiration_in_days_value - days_since_exam_passed)
  end

  def incomplete?
    !passed?
  end

  def retake_course?
    return true if failed? && course_max_test_retakes == 0

    (failed? && ((exams.size % course_max_test_retakes) == 0)) || expiring_soon?
  end

  def mark_completed!
    exams.create!(passed: true)
  end

  def grade_exam!(answers)
    exams.build.grade!(answers)
  end

  private

  def days_since_exam_passed
    (Date.current - passed_exam.created_at.to_date).to_i
  end

  def course_has_at_least_one_question
    if course.questions.none?
      errors.add(:base, 'You cannot assign a course with no questions')
    end
  end
end
