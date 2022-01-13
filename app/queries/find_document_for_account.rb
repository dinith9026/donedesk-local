class FindDocumentForAccount < ApplicationQuery
  def initialize(account, id)
    @account = account
    @id = id
  end

  def query
    @account.documents.find(@id)
  end
end
