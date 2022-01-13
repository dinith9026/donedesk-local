class FindAssignmentForEmployee < ApplicationQuery
  def initialize(employee_record_id, assignment_id)
    @employee_record_id = employee_record_id
    @assignment_id = assignment_id
  end

  def query
    Assignment.find_by!(employee_record_id: @employee_record_id,
                        id: @assignment_id)
  end
end
