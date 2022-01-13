class ListAccounts < ApplicationQuery
  def query
    Account.all
  end
end
