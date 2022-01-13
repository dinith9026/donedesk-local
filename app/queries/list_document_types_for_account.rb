class ListDocumentTypesForAccount < ApplicationQuery
  def initialize(account)
    @account = account
  end

  def query
    DocumentType.where(account_id: @account.id)
                .or(where_canned)
  end

  private

  def where_canned
    DocumentType.where(account_id: nil)
  end
end
