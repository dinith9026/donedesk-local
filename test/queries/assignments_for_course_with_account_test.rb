require 'test_helper'

class AssignmentsForCourseWithAccountTest < ActiveSupport::TestCase
  describe '#query' do
    test 'when course is canned' do
      account = accounts(:oceanview_dental)
      course = courses(:canned)
      assignment_canned = assignments(:oceanview_canned)
      other_assignment_canned = assignments(:brookside_canned)
      subject = AssignmentsForCourseWithAccount.new(course.id, account.id)

      result = subject.query

      assert_includes result, assignment_canned
      refute_includes result, other_assignment_canned
    end

    test 'when course belongs to account' do
      account = accounts(:oceanview_dental)
      course = courses(:oceanview_handbook)
      assignment = assignments(:oceanview_handbook_for_employee)
      other_assignment = assignments(:brookside_handbook)
      subject = AssignmentsForCourseWithAccount.new(course.id, account.id)

      result = subject.query

      assert_includes result, assignment
      refute_includes result, other_assignment
    end
  end
end
