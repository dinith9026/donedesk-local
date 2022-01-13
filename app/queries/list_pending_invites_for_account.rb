class ListPendingInvitesForAccount < ApplicationQuery
  def initialize(account_id)
    @account_id = account_id
  end

  def query
    User
      .left_outer_joins(:employee_record)
      .where(account_id: @account_id, role: ['employee', 'account_manager'])
      .where('confirmation_token IS NOT NULL AND last_sign_in_at IS NULL')
      .where("employee_records.status IS NULL OR employee_records.status = #{EmployeeRecord.statuses[:employed]}")
  end
end
