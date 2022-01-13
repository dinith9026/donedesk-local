class Course < ApplicationRecord
  include Deactivateable

  attr_accessor :is_canned

  TWELVE_HOURS_IN_SECONDS = 43200
  MAX_ALLOWED_QUESTIONS = 25
  MAX_MATERIAL_SIZE_IN_GB = 10
  MAX_MATERIAL_SIZE_IN_BYTES = MAX_MATERIAL_SIZE_IN_GB * 1e+9
  ALLOWED_FILE_TYPES = %w(application/pdf video/3gpp2 video/3gpp2 video/mp4
                          video/x-msvideo video/mpeg video/ogg video/webm)
  ALLOWED_SUPPLEMENT_TYPES = %w(application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
                                application/vnd.ms-powerpoint application/vnd.openxmlformats-officedocument.presentationml.presentation application/zip
                                application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.ms-excel)

  belongs_to :account, optional: true
  has_many :assignments
  has_many :questions, -> { order(created_at: :asc) }
  has_many :employee_records, through: :assignments
  has_many :exams, through: :assignments
  has_many :courses_tracks
  has_many :tracks, through: :courses_tracks

  delegate :for_employed_employees, to: :assignments, prefix: true

  enum certificate_type: { general: 1, osha: 2, hipaa: 3, osha_hipaa: 4, ce: 5  }
  enum compliance_expiration_in_days: { never: 0, three_months: 90,
                                        six_months: 180, one_year: 365 }

  include CommonCourseValidations

  validates :material_s3_key, presence: true
  validates :title, uniqueness: { scope: :account_id,
                                  case_sensitive: false,
                                  allow_blank: true }
  validate :states_are_all_valid

  scope :canned, -> { where(account_id: nil) }
  scope :custom, -> (account) { where(account_id: account.id) }
  scope :for_no_states, -> { where("states = '{}'") }
  scope :for_states, -> (states) {
    where("upper(states::text)::text[] && '{#{states.map(&:upcase).join(",")}}'")
  }
  scope :for_account, -> (account) {
    custom(account)
      .or(canned.for_no_states)
      .or(canned.for_states(account.states))
      .order(:title)
  }

  def supplement_filenames
    supplements.map { |supplement| File.basename(supplement) }
  end

  def belongs_to_another_track?(current_track)
    tracks.reject { |track| current_track.id == track.id }.any?
  end

  def active_tracks
    tracks.active
  end

  def unassigned_employees
    EmployeeRecord
      .joins("LEFT JOIN assignments " \
             "ON assignments.employee_record_id = employee_records.id " \
             "AND assignments.course_id = #{quote(id)}")
      .where("assignments.employee_record_id IS NULL")
      .active
  end

  def assignable_for?(state)
    raise State::InvalidCode.new(state) unless State.valid_code?(state)

    assignable? && required_for_state?(state)
  end

  def assignable?
    active? && questions.any?
  end

  def passed_assignments_for_employed_employees(employee_record_ids)
    assignments_for_employed_employees(employee_record_ids).select(&:passed?)
  end

  def material_url
    donedesk_config = Rails.configuration.donedesk

    creds   = donedesk_config.aws_credentials
    region  = donedesk_config.aws_region
    bucket  = donedesk_config.aws_s3_bucket

    s3      = Aws::S3::Client.new(region: region, credentials: creds)
    signer  = Aws::S3::Presigner.new(client: s3)

    signer.presigned_url(
      :get_object,
      bucket: bucket,
      key: material_s3_key,
      expires_in: TWELVE_HOURS_IN_SECONDS
    )
  end

  def material_type
    mime_type = material_content_type

    case
    when mime_type == nil
      'unknown'
    when mime_type == 'application/pdf'
      'pdf'
    when mime_type.include?('video') || mime_type.include?('mp4') || mime_type.include?('webm')
      'video'
    else
      'unsupported'
    end
  end

  def material_content_type
    MIME::Types.type_for(material_s3_key).first.try(:content_type)
  end

  def material_file_name
    File.basename(material_s3_key)
  end

  def has_expiration?
    'never' != compliance_expiration_in_days
  end

  def compliance_expiration_in_days_value
    Course.compliance_expiration_in_days[compliance_expiration_in_days]
  end

  def canned?
    account.nil?
  end
  alias_method :is_canned?, :canned?

  def custom?
    !canned?
  end

  def assigned?
    assignments.any?
  end

  def question_limit_reached?
    questions.count >= MAX_ALLOWED_QUESTIONS
  end

  private

  def required_for_state?(state)
    states.none? || states.include?(state.to_s.upcase)
  end

  def states_are_all_valid
    if states && invalid_state_codes.any?
      errors.add(:states, "contain invalid value(s): #{invalid_state_codes.join(", ")}")
    end
  end

  def invalid_state_codes
    @invalid_state_codes ||= states.reject { |code| State.valid_code?(code) }
  end

  def quote(value)
    ActiveRecord::Base.connection.quote(value)
  end
end
