class ActiveAccountUsers < ApplicationQuery
  def initialize(account)
    @account = account
  end

  # Checking for a status of `nil` means users that don't have an
  # employee record, e.g. Account Owner, will still be included.
  def query
    @account.users
      .left_joins(:employee_record)
      .where(employee_records: { status: [:employed, nil] })
  end
end
