class FindDocument < ApplicationQuery
  def initialize(id)
    @id = id
  end

  def query
    Document.find(@id)
  end
end