class ListOfficesForAccount < ApplicationQuery
  def initialize(account_id)
    @account_id = account_id
  end

  def query
    Office.where(account_id: @account_id)
  end
end
