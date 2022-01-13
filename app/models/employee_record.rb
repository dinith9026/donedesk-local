class EmployeeRecord < ApplicationRecord
  include Personable

  class UnassignableCourse < StandardError
    def initialize(course, employee)
      super("`#{course.title}` cannot be assigned to `#{employee.full_name}`")
    end
  end

  ATTR_ENCRYPTION_KEY = DoneDesk::Secrets.attr_encryption_key

  belongs_to :office
  belongs_to :user, optional: true
  belongs_to :document_group
  has_one :account, through: :office
  has_many :employee_documents
  has_many :documents, through: :employee_documents
  has_many :assignments
  has_many :assigned_courses, through: :assignments, source: :course
  has_many :assigned_tracks
  has_many :time_entries
  has_many :pto_entries
  has_many :employee_notes
  has_many :document_types_groupings, through: :document_group
  has_many :offices_users, through: :user
  has_many :assigned_offices, through: :offices_users, source: :office
  has_many :certificates

  attr_encrypted :address, key: ATTR_ENCRYPTION_KEY, encode: true, encode_iv: true
  attr_encrypted :dob, key: ATTR_ENCRYPTION_KEY, marshal: true, marshaler: DateMarshaler, encode: true, encode_iv: true
  attr_encrypted :phone, key: ATTR_ENCRYPTION_KEY, encode: true, encode_iv: true
  attr_encrypted :emergency_contact_name, key: ATTR_ENCRYPTION_KEY, encode: true, encode_iv: true
  attr_encrypted :emergency_contact_relationship, key: ATTR_ENCRYPTION_KEY, encode: true, encode_iv: true
  attr_encrypted :emergency_contact_phone, key: ATTR_ENCRYPTION_KEY, encode: true, encode_iv: true
  attr_encrypted :emergency_contact_email, key: ATTR_ENCRYPTION_KEY, encode: true, encode_iv: true

  enum employment_type: EmploymentTypes::VALUES
  enum status: { employed: 1, suspended: 2, terminated: 3 }
  enum marital_status: { single: 1, married: 2 }

  validates :first_name, :last_name, :office_id, :employment_type, :document_group_id, presence: true

  delegate :name, :state, :time_zone, to: :office, prefix: true
  delegate :account, :email, :account_admin?, :account_manager?, :gravatar_url, to: :user, prefix: true
  delegate :id, :name, to: :account, prefix: true
  delegate :name, to: :document_group, prefix: true

  default_scope { order(:last_name) }
  scope :active, -> { employed }
  scope :with_active_account, -> { joins(:account).merge(Account.active) }
  scope :with_login, -> { where('user_id IS NOT NULL') }
  scope :tracks_time, -> { joins(:office).where(offices: { tracks_time: true }) }

  def send_compliance_summary_email?(compliance_summary)
    !compliance_summary.compliant? && user.present? && user.send_compliance_summary_email
  end

  def has_login?
    user.present?
  end

  def terminated!
    update!(status: :terminated, terminated_on: Time.now.utc)
  end

  def employed!
    update!(status: :employed, terminated_on: nil)
  end

  def time_cards_for(date_range, time_card_class = TimeCard)
    (date_range.begin.to_date..date_range.end.to_date).map do |day|
      time_card_class.new(self, day)
    end
  end

  def tracks_time?
    office.tracks_time
  end

  def has_missing_or_expired_documents?
    has_missing_documents? || has_expired_documents?
  end

  def has_missing_or_expired_documents_cached?
    if account.cached_compliance_stats_available_for_employee?(self) && account.cached_compliance_status_current_for_employee?(self)
      MissingDocument.where(employee_record_id: id).any?  ||
        ExpiredDocument.where(employee_record_id: id).any?
    else
      has_missing_or_expired_documents?
    end
  end

  def incomplete_assignments
    active_assignments.select do |assignment|
      assignment.incomplete?
    end
  end

  def active_assignments
    assignments.select do |assignment|
      assignment.course_active?
    end
  end

  def assign_course!(course)
    raise UnassignableCourse.new(course, self) unless course_assignable?(course)
    assignments.create!(course: course)
  end

  def assignable_courses
    account.courses.includes(:questions).select do |course|
      course.assignable_for?(office_state) && !course_assigned?(course)
    end
  end

  def assignable_tracks
    account.tracks.active - assigned_tracks.map(&:track)
  end

  def expired_course_assignments
    active_assignments.select { |assignment| assignment.expired? }
  end

  def expiring_course_assignments
    active_assignments.select { |assignment| assignment.expiring_soon? }
  end

  def has_missing_documents?
    missing_documents.any?
  end

  def missing_documents
    required_documents.reject do |document_type|
      has_document?(document_type)
    end
  end

  def has_expired_documents?
    expired_documents.any?
  end

  def expired_documents
    expirable_documents.select do |document|
      document.expired?
    end
  end

  def expirable_documents
    current_documents.select do |document|
      document.expirable?
    end
  end

  def has_document?(document_type)
    document_for(document_type).present?
  end

  def document_for(document_type)
    current_documents.find do |document|
      document.document_type_id == document_type.id
    end
  end

  def documents_for(document_type_id)
    employee_documents.select do |employee_document|
      employee_document.document_type_id == document_type_id
    end.sort_by(&:created_at).reverse
  end

  def has_documents_expiring_soon?
    documents_expiring_soon.any?
  end

  def documents_expiring_soon
    expirable_documents.select do |document|
      document.expiring_soon?
    end
  end

  def required_documents
    document_group
      .document_types_groupings
      .select(&:required)
      .map(&:document_type)
  end

  def current_documents
    grouped_by_document_type.map do |_, v|
      unexpirable = v.reject(&:expirable?)
      expirable = v.select(&:expirable?)

      if expirable.any?
        v.select(&:expirable?).max_by { |d| d.expires_in }
      else
        unexpirable.max_by { |d| d.created_at }
      end
    end.compact
  end

  def build_document(document)
    EmployeeDocument.new(employee_record: self, document: document)
  end

  private

  def grouped_by_document_type
    employee_documents.group_by { |d| d.document_type_id }
  end

  def course_assigned?(course)
    assigned_courses.include?(course)
  end

  def course_assignable?(course)
    assignable_courses.include?(course)
  end
end
