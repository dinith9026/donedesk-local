class Document < ApplicationRecord
  EXPIRING_SOON_THRESHOLD = 45 # days
  MAX_DOCUMENT_SIZE_IN_GB = 5
  MAX_DOCUMENT_SIZE_IN_BYTES = MAX_DOCUMENT_SIZE_IN_GB * 1e+9
  ALLOWED_FILE_TYPES = %w(image/jpeg image/jpg image/png application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document application/zip)

  has_attached_file :file, url: '/system/:class/:attachment/:id/:filename'
  validates_attachment :file,
    presence: true,
    size: { in: 0..5.gigabytes },
    content_type: { content_type: ALLOWED_FILE_TYPES},
    if: Proc.new { |d| d.new_record? },
    unless: Proc.new { |d| d.is_a?(Paperclip::Attachment) }

  delegate :expiring_url, to: :file, prefix: true
  delegate :full_name, :office, :office_name, :first_initial_and_last, to: :employee_record, prefix: true
  delegate :account_id, to: :employee_record
  delegate :name, :is_confidential, to: :document_type

  alias_method :title, :name

  belongs_to :employee_record
  belongs_to :document_type
  has_many :employee_documents

  validates :document_type_id, presence: true
  validates :expires_on,
    date: { after: Proc.new { Date.current },
            message: 'must be after today',
            allow_blank: true }

  def file_name
    file_file_name
  end

  def status
    if expirable? && expired?
      'Expired'
    elsif expirable? && expiring_soon?
      'Expiring Soon'
    else
      'Valid'
    end
  end

  def expirable?
    expires_on.present?
  end

  def expired?
    raise blank_expiration_error_msg(__method__.to_s) if expires_on.blank?

    expires_on.to_date < Date.current
  end

  def expiring_soon?
    if !expired? && days_until_expired <= EXPIRING_SOON_THRESHOLD
      true
    else
      false
    end
  end

  def expires_in
    days_until_expired
  end

  def download_disposition
    if is_pdf? || is_image?
      'inline'
    else
      'attachment'
    end
  end

  private

  def days_until_expired
    raise blank_expiration_error_msg(__method__.to_s) if expires_on.blank?

    (expires_on.to_date - Date.current).to_i
  end

  def blank_expiration_error_msg(method)
    "Calling `##{method}` when no expiration exists is not allowed. Use `#expirable?`."
  end

  def is_pdf?
    file_content_type == 'application/pdf'
  end

  def is_image?
    file_content_type.to_s.split('/').first == 'image'
  end
end
