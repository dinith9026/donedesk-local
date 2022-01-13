class ListDocumentsForAccount < ApplicationQuery
  def initialize(account)
    @account = account
  end

  def query
    @account.documents
  end
end