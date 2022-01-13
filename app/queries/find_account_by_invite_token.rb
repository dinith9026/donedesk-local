class FindAccountByInviteToken < ApplicationQuery
  def initialize(invite_token)
    @invite_token = invite_token
  end

  def query
    Account.find_by!(invite_token: @invite_token)
  end
end
