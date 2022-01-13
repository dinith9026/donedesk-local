class DocumentForm < ApplicationForm
  attribute :document_type_id, String
  attribute :summary, String
  attribute :expires_on, Date
  attribute :file, ActionDispatch::Http::UploadedFile

  validates :document_type_id, presence: true
  validates :file, presence: true, if: Proc.new { |df| df.new_record? }
  validates :expires_on,
    date: { after: Proc.new { Date.current },
            message: 'must be after today',
            allow_blank: true }

  validate :document_file_content_type_is_allowed,
              unless: Proc.new { file.is_a?(Paperclip::Attachment) }
  validate :document_file_size_is_within_allowed_limit,
              unless: Proc.new { file.is_a?(Paperclip::Attachment) }

  def document_types_list
    context.document_types
  end

  def new_document_path
    context.new_document_path
  end

  def expires_on_formatted
    if expires_on.present?
      I18n.l(expires_on.to_date, format: :default)
    else
      ''
    end
  end

  def file_name
    file.instance.file_file_name
  end

  def cancel_path
    if context.user.has_role?(:employee)
      dashboard_path
    else
      documents_path
    end
  end

  private

  def document_file_size_is_within_allowed_limit
    return if file.nil?

    if File.size(file.tempfile) > Document::MAX_DOCUMENT_SIZE_IN_BYTES
      errors.add(:file, 'too large')
    end
  end

  # content type can be spoofed, but this is good enough here, since we
  # only care about helping out a well-intentioned user, not a malicious one.
  # The Paperclip gem being used on the model, will do a more thorough check
  # of the content type, so we'll rely on that as a fail-safe.
  def document_file_content_type_is_allowed
    return if file.nil?

    unless Document::ALLOWED_FILE_TYPES.include?(file.content_type.to_s)
      errors.add(:file, 'type not allowed')
    end
  end
end
