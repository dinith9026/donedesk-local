require 'test_helper'

class FindExamForAccountTest < ActiveSupport::TestCase
  describe '#query' do
    test 'when exam does NOT belong to account' do
      account = accounts(:oceanview_dental)
      another_exam = exams(:another_exam)

      assert_raises ActiveRecord::RecordNotFound do
        FindExamForAccount.new(account, another_exam.id).query
      end
    end

    test 'when exam belongs to account' do
      account = accounts(:oceanview_dental)
      exam = exams(:failed_for_oceanview_handbook_for_employee)

      result = FindExamForAccount.new(account, exam.id).query

      assert_equal exam.id, result.id
    end

    test 'when exam course is canned' do
      account = accounts(:oceanview_dental)
      exam = exams(:for_oceanview_canned)

      result = FindExamForAccount.new(account, exam.id).query

      assert_equal exam.id, result.id
    end
  end
end
