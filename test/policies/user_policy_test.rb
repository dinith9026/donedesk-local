require 'test_helper'

class UserPolicyTest < PolicyTest
  describe '#show' do
    test 'for super_admin' do
      user = users(:super_admin)
      record = users(:employee)

      assert_permit(:show, user, record)
    end

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test "when record does NOT belong to user's account" do
          user = users(role)
          record = users(:another_employee)

          refute_permit(:show, user, record)
        end

        test "when record belongs to user's account" do
          user = users(role)
          record = users(:employee)

          assert_permit(:show, user, record)
        end
      end
    end

    describe 'for employee' do
      test 'when record is not their own' do
        user = users(:employee)
        record = users(:another_employee)

        refute_permit(:show, user, record)
      end

      test 'when record is their own' do
        user = users(:employee)
        record = user

        assert_permit(:show, user, record)
      end
    end
  end

  describe '#edit' do
    test 'for super_admin' do
      user = users(:super_admin)
      record = users(:employee)

      assert_permit(:edit, user, record)
    end

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test "when record does NOT belong to user's account" do
          user = users(role)
          record = users(:another_employee)

          refute_permit(:edit, user, record)
        end

        test "when record belongs to user's account" do
          user = users(role)
          record = users(:employee)

          assert_permit(:edit, user, record)
        end
      end
    end

    describe 'for employee' do
      test 'when record is not their own' do
        user = users(:employee)
        record = users(:another_employee)

        refute_permit(:edit, user, record)
      end

      test 'when record is their own' do
        user = users(:employee)
        record = user

        assert_permit(:edit, user, record)
      end
    end
  end

  describe '#update' do
    test 'for super_admin' do
      user = users(:super_admin)
      record = users(:employee)

      assert_permit(:update, user, record)
    end

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test "when record does NOT belong to user's account" do
          user = users(role)
          record = users(:another_employee)

          refute_permit(:update, user, record)
        end

        test "when record belongs to user's account" do
          user = users(role)
          record = users(:employee)

          assert_permit(:update, user, record)
        end
      end
    end

    describe 'for employee' do
      test 'when record is not their own' do
        user = users(:employee)
        record = users(:another_employee)

        refute_permit(:edit, user, record)
      end

      test 'when record is their own' do
        user = users(:employee)
        record = user

        assert_permit(:edit, user, record)
      end
    end
  end

  describe '#make_account_manager' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "for #{role}" do
        user, record = users(role)

        assert_permit(:make_account_manager, user, record)
      end
    end

    test 'for employee' do
      user, record = users(:employee)

      refute_permit(:make_account_manager, user, record)
    end
  end

  describe '#make_employee' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "for #{role}" do
        user, record = users(role)

        assert_permit(:make_employee, user, record)
      end
    end

    test 'for employee' do
      user, record = users(:employee)

      refute_permit(:make_employee, user, record)
    end
  end

  describe '#reinvite' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "for #{role}" do
        user, record = users(role)

        assert_permit(:reinvite, user, record)
      end
    end

    test 'for employee' do
      user, record = users(:employee)

      refute_permit(:reinvite, user, record)
    end
  end

  describe '#setup_2fa' do
    [:super_admin, :account_owner, :account_manager, :employee].each do |role|
      describe "for #{role}" do
        test 'when 2FA is required and not set up' do
          user = users(role)
          user.stubs(:two_factor_required?).returns(true)
          user.stubs(:two_factor_setup?).returns(false)

          assert_permit(:setup_2fa, user, user)
        end

        test 'when 2FA is required and already set up' do
          user = users(role)
          user.stubs(:two_factor_required?).returns(true)
          user.stubs(:two_factor_setup?).returns(true)

          refute_permit(:setup_2fa, user, user)
        end

        test 'when 2FA is NOT required' do
          user = users(role)
          user.stubs(:two_factor_required?).returns(false)

          refute_permit(:setup_2fa, user, user)
        end
      end
    end
  end

  describe '#destroy' do
    test 'when employee record exists' do
      user = users(:account_owner)
      record = users(:employee)

      refute_permit(:destroy, user, record)
    end

    [:super_admin, :account_owner, :account_manager].each do |role|
      test "for #{role}" do
        user = users(role)
        record = build(:user, :employee, employee_record: nil)

        assert_permit(:destroy, user, record)
      end
    end

    test 'for employee' do
      user = users(:employee)
      record = build(:user, :employee)

      refute_permit(:destroy, user, record)
    end
  end

  describe '#permitted_attributes' do
    test 'super_admin' do
      user = users(:super_admin)
      subject = UserPolicy.new(user, nil)
      expected = [ :avatar, :email, :first_name, :last_name, :two_factor_enabled ]

      result = subject.permitted_attributes

      assert_equal expected, result
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "for #{role} role" do
        user = users(role)
        subject = UserPolicy.new(user, nil)
        expected = [ :avatar, :email, :first_name, :last_name ]

        result = subject.permitted_attributes

        assert_equal expected, result
      end
    end
  end
end
