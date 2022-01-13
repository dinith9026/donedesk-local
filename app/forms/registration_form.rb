class RegistrationForm < ApplicationForm
  attribute :password, String
  attribute :password_confirmation, String
  attribute :terms
  attribute :stripe_token, String

  validates :terms, acceptance: true
  validates :password, presence: true, confirmation: true
  validates :password,
              length: { minimum: DoneDesk::MIN_PASSWORD_LENGTH },
              password: true,
              if: Proc.new { |f| f.password.present? }, allow_blank: true

  def when_payment_already_added(&block)
    if stripe_token.present?
      yield
    end
  end

  def when_payment_required(&block)
    unless stripe_token.present?
      yield
    end
  end
end
