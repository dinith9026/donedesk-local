class User < ApplicationRecord
  include Personable
  include Clearance::User
  include Storext.model

  MAX_AVATAR_SIZE_IN_MB = 10
  MAX_AVATAR_SIZE_IN_BYTES = MAX_AVATAR_SIZE_IN_MB * 1e+6
  ALLOWED_AVATAR_TYPES = %w(image/jpeg image/jpg image/png image/gif)
  ATTR_ENCRYPTION_KEY = DoneDesk::Secrets.attr_encryption_key

  attr_encrypted :otp_secret_key, key: ATTR_ENCRYPTION_KEY, encode: true, encode_iv: true

  # 2FA
  has_one_time_password

  store_attributes :settings do
    send_compliance_summary_email Boolean, default: true
  end

  store_attributes :chat_terms do
    accepted_at Time
    ip_address String
  end

  has_attached_file :avatar,
    styles: { medium: "300x300#" },
    url: '/system/:class/:attachment/:id/:filename',
    default_url: "/assets/avatars/:style/missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  belongs_to :account, optional: true
  has_one :employee_record
  has_one :office, through: :employee_record
  has_many :offices_users
  has_many :assigned_offices, through: :offices_users, source: :office

  delegate :id, :custom_courses, :offices, :deactivated?, :name,
            to: :account, prefix: true, allow_nil: true
  delegate :id, :assignments, :employed?, :suspended?, :terminated?,
            to: :employee_record, prefix: true, allow_nil: true
  delegate :employee_records, :offices, :two_factor_enabled, to: :account, prefix: true

  enum role: { super_admin: 1, account_owner: 3, account_manager: 4, employee: 5  }

  validates :first_name, :last_name, presence: true
  validates :password,
              length: { minimum: DoneDesk::MIN_PASSWORD_LENGTH },
              password: true,
            if: Proc.new { |f| f.password.present? }, allow_blank: true
  validate :chat_terms_valid, if: Proc.new { |f| f.chat_terms.present? }

  def has_accepted_chat_terms?
    chat_terms.present?
  end

  def gravatar_url(size = 100)
    url = 'https://www.gravatar.com/avatar/'

    if email
      gravatar = Digest::MD5::hexdigest(email).downcase
      url << "#{gravatar}.png"
    end

    url << "?s=#{size}&default=mp"
  end

  def time_zone
    office&.time_zone || 'UTC'
  end

  def tracks_time?
    employee_record.present? && account.time_tracking && employee_record.tracks_time?
  end

  def self.generate_valid_password
    "Z#{SecureRandom.hex}9"
  end

  def change_role_to!(new_role)
    old_role = role

    update!(role: new_role.to_s)

    if old_role == 'account_manager'
      assigned_offices.delete_all
    end
  end

  def has_role?(the_role)
    role.to_s == the_role.to_s
  end

  def has_account?
    account.present?
  end

  def account_admin?
    [:account_owner, :account_manager].include?(role.to_sym)
  end

  def course_assignments
    employee_record_assignments
  end

  def user_hash_for_intercom
    OpenSSL::HMAC.hexdigest(
      'sha256',
      DoneDesk::Secrets.intercom_api_secret,
      id
    )
  end

  def two_factor_qr_code_uri
    provisioning_uri("DoneDesk:#{email}")
  end

  def generate_two_factor_secret_if_missing!
    return unless otp_secret_key.nil?
    update!(otp_secret_key: User.otp_random_secret)
  end

  def two_factor_required?
    two_factor_enabled === true ||
      (!two_factor_enabled_set? && (account.nil? || account_two_factor_enabled?))
  end

  def two_factor_enabled_set?
    two_factor_enabled != nil
  end

  def account_two_factor_enabled?
    account.two_factor_enabled === true
  end

  def two_factor_setup?
    two_factor_setup_at.present?
  end

  def two_factor_setup!
    touch(:two_factor_setup_at)
  end

  private

  def chat_terms_valid
    if chat_terms['accepted_at'].blank? || chat_terms['ip_address'].blank?
      errors.add(:chat_terms, 'are invalid')
    end
  end
end
