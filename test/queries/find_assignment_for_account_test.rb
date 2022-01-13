require 'test_helper'

class FindAssignmentForAccountTest < ActiveSupport::TestCase
  describe '#query' do
    test 'when assignment belongs to account' do
      account = accounts(:oceanview_dental)
      assignment = account.assignments.first

      result = FindAssignmentForAccount.new(account, assignment.id).query

      assert_equal assignment, result
    end

    test 'when assignment does not belong to account' do
      account = accounts(:oceanview_dental)
      other_account = accounts(:brookside_dental)
      assignment = other_account.assignments.first

      assert_raises ActiveRecord::RecordNotFound do
        FindAssignmentForAccount.new(account, assignment.id).query
      end
    end
  end
end
