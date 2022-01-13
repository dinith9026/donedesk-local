class InviteForm < ApplicationForm
  attribute :email, StrippedString
  attribute :role, String, default: 'employee'

  validates :email, email: { strict_mode: true, allow_blank: true }, presence: true
  validate :email_is_unique

  def form_action
    employee_record_invites_path(employee_record)
  end

  def employee_name
    employee_record.full_name
  end

  private

  def email_is_unique
    if users_with_email.any?
      errors.add(:email, 'already exists')
    end
  end

  def users_with_email
    UsersWithEmail.new(email).query
  end

  def employee_record
    context&.employee_record
  end
end
