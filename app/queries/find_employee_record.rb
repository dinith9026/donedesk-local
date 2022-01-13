class FindEmployeeRecord < ApplicationQuery
  def initialize(id)
    @id = id
  end

  def query
    EmployeeRecord.find(@id)
  end
end