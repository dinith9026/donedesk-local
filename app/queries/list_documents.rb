class ListDocuments < ApplicationQuery
  def query
    Document.all
  end
end