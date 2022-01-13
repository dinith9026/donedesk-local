class BaseAccountForm < ApplicationForm
  attribute :name, String
  attribute :time_tracking, Boolean, default: false
  attribute :two_factor_enabled, Boolean

  validates :name, presence: true
  validate :name_is_unique

  def when_account_is_new(&block)
    if new_record?
      yield(block)
    end
  end

  private

  def name_is_unique
    if accounts_with_name.where.not(id: id).any?
      errors.add(:name, 'already taken')
    end
  end

  def accounts_with_name
    AccountsWithName.new(name).query
  end
end
