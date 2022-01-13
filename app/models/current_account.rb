class CurrentAccount
  def self.load(current_user, session)
    return current_user.account unless current_user.super_admin?

    current_account_id = session[:current_account_id]

    if current_account_id.present?
      FindAccount.new(current_account_id).query
    else
      ListAccounts.new.first
    end
  end

  def self.set(account, session)
    session[:current_account_id] = account.id
  end
end
