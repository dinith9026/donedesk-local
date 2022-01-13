class FindOfficeForAccount < ApplicationQuery
  def initialize(account_id, office_id)
    @account_id = account_id
    @office_id = office_id
  end

  def query
    Office.find_by!(id: @office_id,
                    account_id: @account_id)
  end
end
