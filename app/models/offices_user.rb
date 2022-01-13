class OfficesUser < ApplicationRecord
  belongs_to :user
  belongs_to :office

  validate :user_is_an_account_manager

  private

  def user_is_an_account_manager
    unless user.account_manager?
      errors.add(:user, 'must have the account_manager role')
    end
  end
end
