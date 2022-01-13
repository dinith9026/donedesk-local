require 'test_helper'

class ExamPolicyTest < PolicyTest
  describe '#show?' do
    [:super_admin, :account_owner].each do |role|
      test "for #{role}" do
        exam = exams(:failed_for_oceanview_handbook_for_employee)
        user = users(role)

        refute_permit(:show, user, exam)
      end
    end

    [:employee, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when exam does NOT belong to user' do
          exam = exams("failed_for_oceanview_handbook_for_#{role}")
          user = users(:another_employee)

          refute_permit(:show, user, exam)
        end

        test 'when exam belongs to user' do
          exam = exams("failed_for_oceanview_handbook_for_#{role}")
          user = users(role)

          assert_permit(:show, user, exam)
        end
      end
    end
  end
end
