class RequiredDocumentTypesForAccount < ApplicationQuery
  def initialize(account_id)
    @account_id = account_id
  end

  def query
    DocumentType.where(required: true, account_id: @account_id)
                .or(where_required_and_canned)
  end

  private

  def where_required_and_canned
    DocumentType.where(required: true, account_id: nil)
  end
end
