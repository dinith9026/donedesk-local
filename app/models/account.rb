class Account < ApplicationRecord
  include Deactivateable

  has_many :offices, inverse_of: :account
  has_many :employee_records, through: :offices
  has_many :employee_documents, through: :employee_records
  has_many :office_documents, through: :offices
  has_many :documents, through: :employee_records
  has_many :account_employees, foreign_key: :account_id, class_name: 'User'
  has_many :document_groups
  has_many :document_types
  has_many :custom_courses, foreign_key: :account_id, class_name: 'Course'
  has_many :library_documents
  has_many :task
  has_many :exams, through: :courses
  has_many :users, inverse_of: :account
  has_many :tracks, inverse_of: :account
  has_many :assigned_tracks, through: :employee_records
  has_many :time_entries, through: :employee_records
  has_many :pto_entries, through: :employee_records
  has_many :certificates, through: :employee_records
  has_one :plan
  has_one :account_compliance_stats

  alias_attribute :compliance_stats, :account_compliance_stats

  delegate :monthly_price_in_cents, :monthly_price, :max_employees, :interval,
             to: :plan, prefix: true
  delegate :stripe_plan_id, to: :plan
  delegate :employed, :suspended, :terminated, to: :employee_records, prefix: true

  accepts_nested_attributes_for :offices
  accepts_nested_attributes_for :users

  validates :name, presence: true, uniqueness: true

  default_scope { order(:name) }
  scope :inactive, -> { where.not(deactivated_at: nil) }
  scope :registered, -> { where(invite_token: nil) }

  def cached_compliance_stats_available_for_employee?(employee_record)
    compliance_stats_last_updated_at != nil && compliance_stats_last_updated_at > employee_record.created_at
  end

  def cached_compliance_status_current_for_employee?(employee_record)
    employee_record.updated_at > compliance_stats_last_updated_at
  end

  def active_users
    users.joins(:employee_record).merge(EmployeeRecord.employed)
  end

  def office_count
    offices.count
  end

  def states
    raise "Account #{id} must have at least one office" if offices.to_a.empty?
    offices.map(&:state).map(&:upcase)
  end

  def registered?
    invite_accepted?
  end

  def invite_accepted?
    invite_token.to_s.empty?
  end

  def has_invites_remaining?
    invites_remaining > 0
  end

  def invites_remaining
    plan.max_employees.to_i - (active_employee_records.size + users_with_no_employee_record.count)
  end

  def plan_max_employees_reached?
    invites_remaining == 0
  end

  def users_with_no_employee_record
    User
      .where(account_id: id, role: ['employee', 'account_manager'])
      .where('id NOT IN (SELECT user_id FROM employee_records WHERE user_id IS NOT NULL)')
  end

  def pending_invites
    ListPendingInvitesForAccount.new(id).query
  end

  def pending_employee_records
    ListPendingEmployeeRecordsForAccount.new(id).query
  end

  def clear_invite_token!
    update!(invite_token: nil)
  end

  def courses
    Course.for_account(self)
  end

  def find_course!(course_id)
    not_found_error = "Course #{course_id} for Account #{id} not found"
    ifnone = lambda { raise ActiveRecord::RecordNotFound, not_found_error }

    courses.find(ifnone) do |course|
      course.id == course_id
    end
  end

  def assignments
    AssignmentsForAccount.new(id).query
  end

  def active_assignments
    assignments.includes(:course, :employee_record, :exams).active
  end

  def incomplete_assignments
    active_assignments.select do |assignment|
      assignment.incomplete?
    end
  end

  def assignments_for_course(course)
    AccountCourse.new(self, course).assignments
  end

  def passed_assignments_for_course(course)
    AccountCourse.new(self, course).passed_assignments
  end

  def unassigned_employees_for_course(course)
    AccountCourse.new(self, course).unassigned_employees
  end

  def unassigned_employees_for_track(track)
    track.unassigned_employees
  end

  def active_employee_records
    employee_records.active
  end

  def owner
    users.find { |user| user.has_role?(:account_owner) }
  end

  def managers
    users.select { |user| user.has_role?(:account_manager) }
  end

  def owner_email
    owner.email
  end

  def owner_full_name
    owner.full_name
  end

  def owner_first_name
    owner.first_name
  end

  def update_owner_password(password)
    owner.update_password(password)
  end

  def destroy_plan!
    plan.destroy!
  end
end
