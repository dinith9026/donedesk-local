require 'test_helper'

class EmployeeRecordPolicyTest < PolicyTest
  describe '#show?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        employee_record = employee_records(:ed)

        assert_permit(:show, user, employee_record)
      end
    end

    test 'as an employee' do
      user = users(:employee)
      employee_record = employee_records(:ed)
      other_employee_record = employee_records(:ellen)

      assert_permit(:show, user, employee_record)
      refute_permit(:show, user, other_employee_record)
    end
  end

  describe '#update?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        employee_record = employee_records(:ed)

        assert_permit(:update, user, employee_record)
      end
    end

    test 'as an employee' do
      user = users(:employee)
      employee_record = employee_records(:ed)
      other_employee_record = employee_records(:ellen)

      assert_permit(:update, user, employee_record)
      refute_permit(:update, user, other_employee_record)
    end
  end

  describe '#assign_course?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      describe "as an #{role}" do
        test 'when employed' do
          user = users(role)
          employee_record = employee_records(:ed)
          employee_record.stubs(:employed?).returns(true)

          assert_permit(:assign_course, user, employee_record)
        end

        test 'when NOT employed' do
          user = users(role)
          employee_record = employee_records(:ed)
          employee_record.stubs(:employed?).returns(false)

          refute_permit(:assign_course, user, employee_record)
        end
      end
    end

    test 'as an employee' do
      user = users(:employee)
      employee_record = employee_records(:ed)

      refute_permit(:assign_course, user, employee_record)
    end
  end

  describe '#assign_track?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      describe "as an #{role}" do
        test 'when employed' do
          user = users(role)
          employee_record = employee_records(:ed)
          employee_record.stubs(:employed?).returns(true)

          assert_permit(:assign_track, user, employee_record)
        end

        test 'when NOT employed' do
          user = users(role)
          employee_record = employee_records(:ed)
          employee_record.stubs(:employed?).returns(false)

          refute_permit(:assign_track, user, employee_record)
        end
      end
    end

    test 'as an employee' do
      user = users(:employee)
      employee_record = employee_records(:ed)

      refute_permit(:assign_track, user, employee_record)
    end
  end

  describe '#take_assignments?' do
    [:super_admin, :account_owner].each do |role|
      test "as an #{role}" do
        user = users(role)

        refute_permit(:take_assignments, user, nil)
      end
    end

    [:employee, :account_manager].each do |role|
      describe "as an #{role}" do
        test 'when employee record does not belong to current user' do
          user = users(role)
          other_employee_record = EmployeeRecord.new

          refute_permit(:take_assignments, user, other_employee_record)
        end

        test 'when employee record belongs to current user' do
          user = users(role)

          assert_permit(:take_assignments, user, user.employee_record)
        end
      end
    end
  end

  describe '#list_documents' do
    test 'as a super admin' do
      assert_permit(:list_documents, users(:super_admin), employee_records(:ed))
      assert_permit(:list_documents, users(:super_admin), employee_records(:ellen))
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when employee record does NOT belong to their account' do
          refute_permit(:list_documents, users(role), employee_records(:ellen))
        end

        test 'when employee record belongs to their account' do
          assert_permit(:list_documents, users(role), employee_records(:ed))
        end
      end
    end

    describe 'as an employee' do
      test 'when employee record does NOT belong to user' do
        refute_permit(:list_documents, users(:employee), employee_records(:eric))
      end

      test 'when employee record belongs to user' do
        assert_permit(:list_documents, users(:employee), employee_records(:ed))
      end
    end
  end

  describe '#list_time_cards?' do
    test 'as a super admin' do
      assert_permit(:list_time_cards, users(:super_admin), employee_records(:ed))
      assert_permit(:list_time_cards, users(:super_admin), employee_records(:ellen))
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when employee record does NOT belong to their account' do
          refute_permit(:list_time_cards, users(role), employee_records(:ellen))
        end

        test 'when employee record belongs to their account' do
          assert_permit(:list_time_cards, users(role), employee_records(:ed))
        end
      end
    end

    describe 'as an employee' do
      test 'when employee record does NOT belong to user' do
        refute_permit(:list_time_cards, users(:employee), employee_records(:eric))
      end

      test 'when employee record belongs to user' do
        assert_permit(:list_time_cards, users(:employee), employee_records(:ed))
      end
    end
  end

  describe '#list_time_entries?' do
    test 'as a super admin' do
      assert_permit(:list_time_entries, users(:super_admin), employee_records(:ed))
      assert_permit(:list_time_entries, users(:super_admin), employee_records(:ellen))
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when employee record does NOT belong to their account' do
          refute_permit(:list_time_entries, users(role), employee_records(:ellen))
        end

        test 'when employee record belongs to their account' do
          assert_permit(:list_time_entries, users(role), employee_records(:ed))
        end
      end
    end

    describe 'as an employee' do
      test 'when employee record does NOT belong to user' do
        refute_permit(:list_time_entries, users(:employee), employee_records(:eric))
      end

      test 'when employee record belongs to user' do
        assert_permit(:list_time_entries, users(:employee), employee_records(:ed))
      end
    end
  end

  describe '#list_employee_notes?' do
    test 'as a super admin' do
      assert_permit(:list_employee_notes, users(:super_admin), employee_records(:ed))
      assert_permit(:list_employee_notes, users(:super_admin), employee_records(:ellen))
    end

    describe "as an account_owner" do
      test 'when employee record does NOT belong to their account' do
        refute_permit(:list_employee_notes, users(:account_owner), employee_records(:ellen))
      end

      test 'when employee record belongs to their account' do
        assert_permit(:list_employee_notes, users(:account_owner), employee_records(:ed))
      end
    end

    describe "as an account_manager" do
      test 'when employee record does NOT belong to their account' do
        refute_permit(:list_employee_notes, users(:account_manager), employee_records(:ellen))
      end

      test 'when employee record belongs to their account and is not their own' do
        user = users(:account_manager)
        refute_permit(:list_employee_notes, user, user.employee_record)
      end

      test 'when employee record belongs to their account and is not their own' do
        assert_permit(:list_employee_notes, users(:account_manager), employee_records(:ed))
      end
    end

    test 'as an employee' do
      refute_permit(:list_employee_notes, users(:employee), employee_records(:ed))
    end
  end

  describe '#list_assigned_offices?' do
    test 'as a super admin' do
      refute_permit(:list_assigned_offices, users(:super_admin), employee_records(:ed))
      assert_permit(:list_assigned_offices, users(:super_admin), employee_records(:mary))
      refute_permit(:list_assigned_offices, users(:super_admin), employee_records(:with_no_user))
    end

    describe "as an account_owner" do
      test 'when employee record does NOT belong to their account' do
        refute_permit(:list_assigned_offices, users(:account_owner), employee_records(:ellen))
      end

      test 'when employee record belongs to their account but has no login' do
        employee_record = employee_records(:ed)
        employee_record.stubs(:has_login?).returns(false)

        refute_permit(:list_assigned_offices, users(:account_owner), employee_record)
      end

      test 'when employee record belongs to their account and has a login but is not account admin' do
        employee_record = employee_records(:ed)
        refute_permit(:list_assigned_offices, users(:account_owner), employee_record)
      end

      test 'when employee record belongs to their account and has a login and is an account admin' do
        employee_record = employee_records(:mary)
        assert_permit(:list_assigned_offices, users(:account_owner), employee_record)
      end
    end

    test 'as an account_manager' do
      refute_permit(:list_assigned_offices, users(:account_manager), employee_records(:ed))
    end

    test 'as an employee' do
      refute_permit(:list_assigned_offices, users(:employee), employee_records(:ed))
    end
  end

  describe '#new_time_entry?' do
    test 'as a super admin' do
      assert_permit(:new_time_entry, users(:super_admin), employee_records(:ed))
      assert_permit(:new_time_entry, users(:super_admin), employee_records(:ellen))
    end

    [:account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when employee record does NOT belong to their account' do
          refute_permit(:new_time_entry, users(role), employee_records(:ellen))
        end

        test 'when employee record belongs to their account' do
          assert_permit(:new_time_entry, users(role), employee_records(:ed))
        end
      end
    end

    describe 'as an employee' do
      test 'when employee record does NOT belong to user' do
        refute_permit(:new_time_entry, users(:employee), employee_records(:eric))
      end

      test 'when employee record belongs to user' do
        refute_permit(:new_time_entry, users(:employee), employee_records(:ed))
      end
    end
  end

  describe '#suspend?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        employee_record = employee_records(:ed)

        assert_permit(:suspend, user, employee_record)
      end
    end

    test 'when already suspended' do
      user = users(:account_owner)
      employee_record = build(:employee_record, status: 'suspended')

      refute_permit(:suspend, user, employee_record)
    end

    test 'as an employee' do
      user = users(:employee)
      employee_record = employee_records(:ed)

      refute_permit(:suspend, user, employee_record)
    end
  end

  describe '#unsuspend?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        employee_record = build(:employee_record, status: 'suspended')

        assert_permit(:unsuspend, user, employee_record)
      end
    end

    test 'when not already suspended' do
      user = users(:account_owner)
      employee_record = build(:employee_record, status: 'employed')

      refute_permit(:unsuspend, user, employee_record)
    end

    test 'as an employee' do
      user = users(:employee)
      employee_record = employee_records(:ed)

      refute_permit(:unsuspend, user, employee_record)
    end
  end

  describe '#terminate?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        employee_record = employee_records(:ed)

        assert_permit(:terminate, user, employee_record)
      end
    end

    test 'when already terminated' do
      user = users(:account_owner)
      employee_record = build(:employee_record, status: 'terminated')

      refute_permit(:terminate, user, employee_record)
    end

    test 'as an employee' do
      user = users(:employee)
      employee_record = employee_records(:ed)

      refute_permit(:terminate, user, employee_record)
    end
  end

  describe '#rehire?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        employee_record = build(:employee_record, status: 'terminated')

        assert_permit(:rehire, user, employee_record)
      end
    end

    test 'when not already terminated' do
      user = users(:account_owner)
      employee_record = build(:employee_record, status: 'employed')

      refute_permit(:rehire, user, employee_record)
    end

    test 'as an employee' do
      user = users(:employee)
      employee_record = employee_records(:ed)

      refute_permit(:rehire, user, employee_record)
    end
  end

  describe '#new_document?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as an #{role}" do
        user = users(role)
        employee_record = employee_records(:ed)

        assert_permit(:new_document, user, employee_record)
      end
    end

    test 'as an employee' do
      user = users(:employee)
      employee_record = employee_records(:ed)
      other_employee_record = employee_records(:ellen)

      assert_permit(:new_document, user, employee_record)
      refute_permit(:new_document, user, other_employee_record)
    end
  end

  describe '#create_employee_note' do
    test 'as a super admin' do
      assert_permit(:create_employee_note, users(:super_admin), employee_records(:ed))
      assert_permit(:create_employee_note, users(:super_admin), employee_records(:ellen))
    end

    describe "as an account_owner" do
      test 'when employee record does NOT belong to their account' do
        refute_permit(:create_employee_note, users(:account_owner), employee_records(:ellen))
      end

      test 'when employee record belongs to their account' do
        assert_permit(:create_employee_note, users(:account_owner), employee_records(:ed))
      end
    end

    describe "as an account_owner" do
      test 'when employee record does NOT belong to their account' do
        refute_permit(:create_employee_note, users(:account_owner), employee_records(:ellen))
      end

      test 'when employee record belongs to their account' do
        assert_permit(:create_employee_note, users(:account_owner), employee_records(:ed))
      end
    end

    describe "as an account_manager" do
      test 'when employee record does NOT belong to their account' do
        refute_permit(:create_employee_note, users(:account_manager), employee_records(:ellen))
      end

      test 'when employee record belongs to their account and is not their own' do
        user = users(:account_manager)
        refute_permit(:create_employee_note, user, user.employee_record)
      end

      test 'when employee record belongs to their account and is not their own' do
        assert_permit(:create_employee_note, users(:account_manager), employee_records(:ed))
      end
    end

    test 'as an employee' do
      refute_permit(:create_employee_note, users(:employee), employee_records(:ed))
    end
  end

  describe '#invite?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when not already invited' do
          user = users(role)
          employee_record = employee_records(:with_no_user)

          assert_permit(:invite, user, employee_record)
        end

        test 'when already invited' do
          user = users(role)
          employee_record = employee_records(:ed)

          refute_permit(:invite, user, employee_record)
        end

        test 'when suspended' do
          user = users(role)
          employee_record = employee_records(:with_no_user)
          employee_record.suspended!

          refute_permit(:invite, user, employee_record)
        end

        test 'when terminated' do
          user = users(role)
          employee_record = employee_records(:with_no_user)
          employee_record.terminated!

          refute_permit(:invite, user, employee_record)
        end
      end
    end

    test 'as an employee' do
      user = users(:employee)
      employee_record = employee_records(:with_no_user)

      refute_permit(:invite, user, employee_record)
    end
  end

  describe '#permitted_attributes' do
    test 'for employee role' do
      user = users(:employee)
      subject = EmployeeRecordPolicy.new(user, nil)
      expected = [
        :user_id, :office_id, :first_name, :last_name, :title, :dob,
        :phone, :address, :marital_status, :employment_type,
        :emergency_contact_name, :emergency_contact_relationship,
        :emergency_contact_phone, :emergency_contact_email, :agd_member_number,
        user: [ :avatar, :email, :role, :first_name, :last_name ]
      ]

      result = subject.permitted_attributes

      assert_equal expected, result
    end

    [:super_admin, :account_owner, :account_manager].each do |role|
      test "for #{role} role" do
        user = users(role)
        subject = EmployeeRecordPolicy.new(user, nil)
        expected = [
          :user_id, :office_id, :first_name, :last_name, :title, :dob,
          :phone, :address, :marital_status, :employment_type,
          :emergency_contact_name, :emergency_contact_relationship,
          :emergency_contact_phone, :emergency_contact_email, :agd_member_number,
          :hired_on, :terminated_on, :document_group_id,
          { track_ids: [] },
          { user: [ :avatar, :email, :role, :first_name, :last_name ] }
        ]

        result = subject.permitted_attributes

        assert_equal expected, result
      end
    end
  end
end
