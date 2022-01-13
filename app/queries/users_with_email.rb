class UsersWithEmail < ApplicationQuery
  def initialize(email)
    @email = email
  end

  def query
    User.where('lower(email) = ?', @email.to_s.downcase)
  end
end
