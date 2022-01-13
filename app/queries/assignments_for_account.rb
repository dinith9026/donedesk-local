class AssignmentsForAccount < ApplicationQuery
  def initialize(account_id)
    @account_id = account_id
  end

  def query
    Assignment.joins(:employee_record)
              .where('employee_records.id' => employees_for_account)
  end

  private

  def employees_for_account
    Office
      .select('employee_records.id')
      .joins(:employee_records)
      .where(account_id: @account_id)
      .where(employee_records: { status: 'employed'})
  end
end
