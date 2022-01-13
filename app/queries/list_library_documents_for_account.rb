class ListLibraryDocumentsForAccount < ApplicationQuery
  def initialize(account_id)
    @account_id = account_id
  end

  def query
    LibraryDocument.where(account_id: @account_id)
                   .or(where_canned)
                   .includes(:account)
                   .order(:name)
  end

  private

  def where_canned
    LibraryDocument.where(account_id: nil)
  end
end
