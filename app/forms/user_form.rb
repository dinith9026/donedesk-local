class UserForm < ApplicationForm
  attribute :email, StrippedString
  attribute :role, String, default: 'employee'
  attribute :first_name, String
  attribute :last_name, String
  attribute :avatar, ActionDispatch::Http::UploadedFile
  attribute :two_factor_enabled, Boolean

  validates :first_name, :last_name, presence: true
  validates :role, inclusion: { in: ['account_manager', 'employee'] }
  validates :email, format: { with: /.+@.+\..+/,
                              message: 'does not appear to be valid' }
  validate :uniqueness_of_email
  validate :avatar_size_is_within_allowed_limit,
              unless: Proc.new { |cf| avatar.is_a?(Paperclip::Attachment) }
  validate :avatar_content_type_is_allowed,
              unless: Proc.new { |cf| avatar.is_a?(Paperclip::Attachment) }

  private

  def uniqueness_of_email
    if users_with_email.where.not(id: id).any?
      errors.add(:email, 'already taken')
    end
  end

  def users_with_email
    UsersWithEmail.new(email).query
  end

  def avatar_size_is_within_allowed_limit
    return if avatar.nil?

    file_size = File.size(avatar.tempfile)

    if file_size > User::MAX_AVATAR_SIZE_IN_BYTES
      errors.add(:avatar, "too large (up to #{User::MAX_AVATAR_SIZE_IN_MB} MB allowed)")
    end
  end

  # Rely on Paperclip's more robust content type validation on the model
  # to prevent spoofing of content-type. Form objects shouldn't care about
  # malicious intent.
  def avatar_content_type_is_allowed
    return if avatar.nil?

    content_type = avatar.content_type.to_s

    unless User::ALLOWED_AVATAR_TYPES.include?(content_type)
      errors.add(:avatar, "type `#{content_type}` not allowed (allowed: JPG, JPEG, PNG, GIF)")
    end
  end
end
