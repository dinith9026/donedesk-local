class AssignedEmployeesForCourse < ApplicationQuery
  def initialize(course_id, account_id)
    @course_id = course_id
    @account_id = account_id
  end

  def query
    assigned_employees_for_course
      .joins(:office, :account)
      .where(accounts: { id: @account_id })
  end

  private

  def assigned_employees_for_course
    EmployeeRecord
      .joins(:assignments)
      .where('assignments.course_id' => @course_id)
  end

  def quoted_course_id
    ActiveRecord::Base.connection.quote(@course_id)
  end
end
