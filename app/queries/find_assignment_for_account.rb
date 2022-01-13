class FindAssignmentForAccount < ApplicationQuery
  def initialize(account, id)
    @account = account
    @id = id
  end

  def query
    @account.assignments.find(@id)
  end
end
