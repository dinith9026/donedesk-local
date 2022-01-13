class LibraryDocumentForm < ApplicationForm
  attribute :account_id, String
  attribute :name, String
  attribute :summary, String
  attribute :file, ActionDispatch::Http::UploadedFile
  attribute :is_canned, Boolean, default: false
  attribute :is_visible_to_employees, Boolean, default: false

  validates :name, presence: true
  validates :file, presence: true,
              unless: Proc.new { |cf| file.is_a?(Paperclip::Attachment) }
  validate :name_is_unique_for_account
  validate :file_size_is_within_allowed_limit,
              unless: Proc.new { |cf| file.is_a?(Paperclip::Attachment) }
  validate :file_content_type_is_allowed,
              unless: Proc.new { |cf| file.is_a?(Paperclip::Attachment) }

  private

  def name_is_unique_for_account
    if account_library_documents_with_name.where.not(id: id).any?
      errors.add(:name, 'already taken')
    end
  end

  def account_library_documents_with_name
    AccountLibraryDocumentsWithName.new(name, account_id).query
  end

  def file_size_is_within_allowed_limit
    return if file.nil?

    if File.size(file.tempfile) > LibraryDocument::MAX_DOCUMENT_SIZE_IN_BYTES
      errors.add(:file, 'too large')
    end
  end

  # Rely on Paperclip's more robust content type validation on the model
  # to prevent spoofing of content-type. Form objects shouldn't care about
  # malicious intent.
  def file_content_type_is_allowed
    return if file.nil?

    unless LibraryDocument::ALLOWED_FILE_TYPES.include?(file.content_type.to_s)
      errors.add(:file, 'type not allowed')
    end
  end
end
