class AccountsWithName < ApplicationQuery
  def initialize(name)
    @name = name
  end

  def query
    Account.where('lower(name) = ?', @name.to_s.downcase)
  end
end

