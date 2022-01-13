require 'test_helper'

class AccountManagerDashboardTest < ActiveSupport::TestCase
  setup do
    @user = build(:user, :account_manager)
  end

  describe '#when_employee_record_exists' do
    test 'when record exists' do
      employee_record = build(:employee_record)
      @user.stubs(:employee_record).returns(employee_record)
      subject = AccountManagerDashboard.new(@user)
      block_called = false

      subject.when_employee_record_exists do
        block_called = true
      end

      assert_equal true, block_called
    end

    test 'when no record exists' do
      @user.stubs(:employee_record).returns(nil)
      subject = AccountManagerDashboard.new(@user)
      block_called = false

      subject.when_employee_record_exists do
        block_called = true
      end

      assert_equal false, block_called
    end
  end

  describe '#when_no_employee_record_exists' do
    test 'when record exists' do
      employee_record = build(:employee_record)
      @user.stubs(:employee_record).returns(employee_record)
      subject = AccountManagerDashboard.new(@user)
      block_called = false

      subject.when_no_employee_record_exists do
        block_called = true
      end

      assert_equal false, block_called
    end

    test 'when no record exists' do
      @user.stubs(:employee_record).returns(nil)
      subject = AccountManagerDashboard.new(@user)
      block_called = false

      subject.when_no_employee_record_exists do
        block_called = true
      end

      assert_equal true, block_called
    end
  end

  test '#new_employee_record_form' do
    subject = AccountManagerDashboard.new(@user)

    assert_instance_of EmployeeRecordForm, subject.new_employee_record_form
  end
end
