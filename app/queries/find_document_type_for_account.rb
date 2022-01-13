class FindDocumentTypeForAccount < ApplicationQuery
  def initialize(account, id)
    @account = account
    @id = id
  end

  def query
    DocumentType
      .where(account_id: @account.id)
      .or(where_canned)
      .find(@id)
  end

  private

  def where_canned
    DocumentType.where(account_id: nil)
  end
end
