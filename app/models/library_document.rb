class LibraryDocument < ApplicationRecord
  attr_accessor :is_canned

  MAX_DOCUMENT_SIZE_IN_GB = 5
  MAX_DOCUMENT_SIZE_IN_BYTES = MAX_DOCUMENT_SIZE_IN_GB * 1e+9
  ALLOWED_FILE_TYPES = %w(image/jpeg image/jpg image/png application/pdf application/msword application/doc application/docx application/x-soffice application/vnd.openxmlformats-officedocument.wordprocessingml.document application/zip)

  has_attached_file :file, url: '/system/:class/:attachment/:id/:filename'
  validates_attachment :file,
    presence: true,
    size: { in: 0..5.gigabytes },
    content_type: { content_type: ALLOWED_FILE_TYPES},
    if: Proc.new { |d| d.new_record? },
    unless: Proc.new { |d| d.is_a?(Paperclip::Attachment) }

  delegate :expiring_url, to: :file, prefix: true

  belongs_to :account, optional: true

  scope :canned, -> { where(account_id: nil) }
  scope :custom, -> (account) { where(account_id: account.id) }

  def file_name
    file_file_name
  end

  def is_canned?
    persisted? && account.nil?
  end

  def is_custom?
    !is_canned?
  end
end
