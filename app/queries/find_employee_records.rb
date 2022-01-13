class FindEmployeeRecords < ApplicationQuery
  def initialize(ids)
    @ids = ids
  end

  def query
    EmployeeRecord.find(@ids)
  end
end
