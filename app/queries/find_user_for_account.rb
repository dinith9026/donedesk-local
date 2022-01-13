class FindUserForAccount < ApplicationQuery
  def initialize(account, user_id)
    @account = account
    @user_id = user_id
  end

  def query
    @account.users.find(@user_id)
  end
end
