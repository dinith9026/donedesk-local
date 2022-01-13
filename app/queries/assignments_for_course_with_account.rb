class AssignmentsForCourseWithAccount < ApplicationQuery
  def initialize(course_id, account_id)
    @course_id = course_id
    @account_id = account_id
  end

  def query
    AssignmentsForAccount.new(@account_id).query.where(course_id: @course_id)
  end
end
