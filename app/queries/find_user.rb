class FindUser < ApplicationQuery
  def initialize(id)
    @id = id
  end

  def query
    User.find(@id)
  end
end
