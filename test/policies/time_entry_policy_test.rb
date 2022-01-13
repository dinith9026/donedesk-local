require 'test_helper'

class TimeEntryPolicyTest < PolicyTest
  describe '#create?' do
    test 'as a super admin' do
      assert_permit(:create, users(:super_admin), TimeEntry)
    end

    describe 'as an account owner' do
      test 'when time entry is for an employee belonging to users account' do
        user = users(:account_owner)
        time_entry = time_entry_for(employee_records(:ed))

        assert_permit(:create, user, time_entry)
      end

      test 'when time entry is for an employee not belonging to users account' do
        user = users(:account_owner)
        time_entry = time_entry_for(employee_records(:ellen))

        refute_permit(:create, user, time_entry)
      end
    end

    describe 'as an account manager' do
      test 'when time entry is for the given employee' do
        user = users(:account_manager)
        time_entry = time_entry_for(user.employee_record)

        assert_permit(:create, user, time_entry)
      end

      test 'when time entry is for a coworker' do
        user = users(:account_manager)
        time_entry = time_entry_for(employee_records(:ed))

        assert_permit(:create, user, time_entry)
      end

      test 'when time entry is for an employee not belonging to users account' do
        user = users(:account_manager)
        time_entry = time_entry_for(employee_records(:ellen))

        refute_permit(:create, user, time_entry)
      end
    end

    describe 'as an employee' do
      test 'when time entry is for the given employee' do
        user = users(:employee)
        time_entry = time_entry_for(user.employee_record)

        assert_permit(:create, user, time_entry)
      end

      test 'when time entry is for a coworker' do
        user = users(:employee)
        time_entry = time_entry_for(employee_records(:eric))

        refute_permit(:create, user, time_entry)
      end
    end
  end

  describe '#permitted_attributes' do
    test 'when user is a super admin' do
      user = users(:super_admin)

      subject = TimeEntryPolicy.new(user, TimeEntry)

      assert_includes subject.permitted_attributes, :occurred_at
    end

    test 'when user is NOT an account admin' do
      user = users(:employee)

      subject = TimeEntryPolicy.new(user, TimeEntry)

      refute_includes subject.permitted_attributes, :occurred_at
    end

    test 'when user is an account admin' do
      user = users(:account_manager)

      subject = TimeEntryPolicy.new(user, TimeEntry)

      assert_includes subject.permitted_attributes, :occurred_at
    end
  end

  private

  def time_entry_for(employee_record)
    TimeEntry.new(employee_record: employee_record)
  end
end
