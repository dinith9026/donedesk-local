require 'test_helper'

class PTOEntryPolicyTest < PolicyTest
  describe '#index?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as a #{role}" do
        assert_permit(:index, users(role), PTOEntry)
      end
    end

    test 'as an employee' do
      refute_permit(:index, users(:employee), PTOEntry)
    end
  end

  describe '#new?' do
    test 'as a super admin' do
      assert_permit(:new, users(:super_admin), PTOEntry)
    end

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when PTO entry is for an employee belonging to users account' do
          user = users(role)
          pto_entry = pto_entry_for(employee_records(:ed))

          assert_permit(:new, user, pto_entry)
        end

        test 'when PTO entry is for an employee not belonging to users account' do
          user = users(role)
          pto_entry = pto_entry_for(employee_records(:ellen))

          refute_permit(:new, user, pto_entry)
        end
      end
    end

    test 'as an employee' do
      refute_permit(:new, users(:employee), PTOEntry)
    end
  end

  describe '#create?' do
    test 'as a super admin' do
      assert_permit(:create, users(:super_admin), PTOEntry)
    end

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when PTO entry is for an employee belonging to users account' do
          user = users(role)
          pto_entry = pto_entry_for(employee_records(:ed))

          assert_permit(:create, user, pto_entry)
        end

        test 'when PTO entry is for an employee not belonging to users account' do
          user = users(role)
          pto_entry = pto_entry_for(employee_records(:ellen))

          refute_permit(:create, user, pto_entry)
        end
      end
    end

    test 'as an employee' do
      refute_permit(:create, users(:employee), PTOEntry)
    end
  end

  describe '#edit?' do
    test 'as a super admin' do
      assert_permit(:edit, users(:super_admin), PTOEntry)
    end

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when record does NOT belong to their account' do
          user = users(role)
          record = pto_entries(:for_brookside_ellen)

          refute_permit(:edit, user, record)
        end

        test 'when record belongs to their account' do
          user = users(role)
          record = pto_entries(:for_oceanview_ed)

          assert_permit(:edit, user, record)
        end
      end
    end

    test 'as an employee' do
      refute_permit(:edit, users(:employee), PTOEntry)
    end
  end

  describe '#update?' do
    test 'as a super admin' do
      assert_permit(:update, users(:super_admin), PTOEntry)
    end

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when record does NOT belong to their account' do
          user = users(role)
          record = pto_entries(:for_brookside_ellen)

          refute_permit(:update, user, record)
        end

        test 'when record belongs to their account' do
          user = users(role)
          record = pto_entries(:for_oceanview_ed)

          assert_permit(:update, user, record)
        end
      end
    end

    test 'as an employee' do
      refute_permit(:update, users(:employee), PTOEntry)
    end
  end

  describe '#destroy?' do
    test 'as a super admin' do
      assert_permit(:destroy, users(:super_admin), PTOEntry)
    end

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when record does NOT belong to their account' do
          user = users(role)
          record = pto_entries(:for_brookside_ellen)

          refute_permit(:destroy, user, record)
        end

        test 'when record belongs to their account' do
          user = users(role)
          record = pto_entries(:for_oceanview_ed)

          assert_permit(:destroy, user, record)
        end
      end
    end

    test 'as an employee' do
      refute_permit(:destroy, users(:employee), PTOEntry)
    end
  end

  private

  def pto_entry_for(employee_record)
    PTOEntry.new(employee_record: employee_record)
  end
end
