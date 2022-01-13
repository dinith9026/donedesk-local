class AccountCourse
  delegate :id, :employee_record_ids, to: :account, prefix: true
  delegate :states, to: :course, prefix: true

  attr_reader :account, :course

  def initialize(account, course)
    @account = account
    @course = course
  end

  def assignments
    @course.assignments_for_employed_employees(account_employee_record_ids)
  end

  def passed_assignments
    @course.passed_assignments_for_employed_employees(account_employee_record_ids)
  end

  def unassigned_employees
    query =
      @course
      .unassigned_employees
      .joins(:office, :account)
      .where(accounts: { id: account_id })

    if course_states.any?
      query.where(offices: { state: course_states })
    else
      query
    end
  end
end
