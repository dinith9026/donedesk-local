class FindAccount < ApplicationQuery
  def initialize(id)
    @id = id
  end
  
  def query
    Account.find(@id)
  end
end