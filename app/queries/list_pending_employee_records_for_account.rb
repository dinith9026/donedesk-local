class ListPendingEmployeeRecordsForAccount < ApplicationQuery
  def initialize(account_id)
    @account_id = account_id
  end

  def query
    User
      .where(account_id: @account_id, role: ['employee', 'account_manager'])
      .where('id NOT IN (SELECT user_id FROM employee_records WHERE user_id IS NOT NULL)')
      .where('confirmation_token IS NULL')
  end
end
