class DeactivateAccount < ApplicationCommand
  def initialize(account)
    @account = account
  end
  def call
    transaction do
      deactivate_account
    end
    broadcast(:ok)
  end

  private

  def deactivate_account
    @account.touch(:deactivated_at)
  end
end
