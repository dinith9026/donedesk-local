class PolicyContext
  attr_reader :user, :account

  def initialize(user, account)
    @user = user
    @account = account
  end
end
