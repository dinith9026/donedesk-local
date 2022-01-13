class AccountsPresenter < CollectionPresenter
  def active
    select { |account| account.active? }
  end

  def deactivated
    select { |account| account.deactivated? }
  end

  def new_path
    new_account_path
  end
end
