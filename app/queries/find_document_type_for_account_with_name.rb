class FindDocumentTypeForAccountWithName < ApplicationQuery
  def initialize(name, account_id)
    @name = name
    @account_id = account_id
  end

  def query
    DocumentType.where(name: @name, account_id: @account_id)
  end
end