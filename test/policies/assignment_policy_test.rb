require 'test_helper'

class AssignmentPolicyTest < PolicyTest
  describe '#index?' do
    [:super_admin, :account_owner].each do |role|
      test "as an #{role}" do
        user = users(role)

        refute_permit(:index, user, nil)
      end
    end

    [:employee, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)

        assert_permit(:index, user, nil)
      end
    end

    test "when no employee record exists" do
      user = User.new(employee_record: nil)

      refute_permit(:index, user, nil)
    end
  end

  describe '#take_exam?' do
    [:super_admin, :account_owner].each do |role|
      test "as an #{role}" do
        user = users(role)

        refute_permit(:take_exam, user, nil)
      end
    end

    [:employee, :account_manager].each do |role|
      describe "as an #{role}" do
        test 'when assignment does NOT belong to user' do
          user = users(role)
          other_assignment = assignments(:brookside_handbook)

          refute_permit(:take_exam, user, other_assignment)
        end

        test 'when assignment belongs to user and exam is takeable' do
          user = users(role)
          assignment = assignments("oceanview_handbook_for_#{role}")
          assignment.stubs(:exam_takeable?).returns(true)

          assert_permit(:take_exam, user, assignment)
        end

        test 'when assignment belongs to user and exam is NOT takeable' do
          user = users(role)
          assignment = assignments("oceanview_handbook_for_#{role}")
          assignment.stubs(:exam_takeable?).returns(false)

          refute_permit(:take_exam, user, assignment)
        end
      end
    end
  end

  describe '#mark_completed?' do
    test 'when assignment passed' do
      user = build(:user)
      assignment = build(:assignment, :passed)

      refute_permit(:mark_completed, user, assignment)
    end

    test 'as a super_admin' do
      user = build(:user, :super_admin)
      assignment = build(:assignment)

      assert_permit(:mark_completed, user, assignment)
    end

    [:account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        assignment = assignments(:oceanview_handbook_for_eric)

        assert_permit(:mark_completed, user, assignment)
      end
    end

    test 'as an employee' do
      user = users(:employee)
      assignment = build(:assignment)

      refute_permit(:mark_completed, user, assignment)
    end
  end

  describe '#show?' do
    [:super_admin, :account_owner].each do |role|
      test "as an #{role}" do
        user = users(role)

        refute_permit(:show, user, nil)
      end
    end

    [:employee, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        assignment = assignments("oceanview_handbook_for_#{role}")

        assert_permit(:show, user, assignment)
      end
    end
  end

  describe '#download?' do
    [:super_admin, :account_owner].each do |role|
      test "as an #{role}" do
        user = users(role)

        refute_permit(:download, user, nil)
      end
    end

    [:employee, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        assignment = assignments("oceanview_handbook_for_#{role}")

        assert_permit(:download, user, assignment)
      end
    end
  end

  describe '#destroy?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      describe "as an #{role}" do
        test 'when course does not belong to a track' do
          assignment = build(:assignment)
          user = users(role)

          assert_permit(:destroy, user, assignment)
        end

        test 'when course belongs to an assigned track' do
          assignment = assignments(:oceanview_handbook_for_employee)
          assignment.stubs(:course_belongs_to_assigned_track?).returns(true)
          user = users(role)

          refute_permit(:destroy, user, assignment)
        end

        test 'when course does NOT belong to an assigned track' do
          assignment = assignments(:oceanview_handbook_for_employee)
          assignment.stubs(:course_belongs_to_assigned_track?).returns(false)
          user = users(role)

          assert_permit(:destroy, user, assignment)
        end
      end
    end

    test 'as an employee' do
      assignment = build(:assignment)
      user = users(:employee)

      refute_permit(:destroy, user, assignment)
    end
  end
end
