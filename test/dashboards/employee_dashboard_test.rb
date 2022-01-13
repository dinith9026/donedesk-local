require 'test_helper'

class EmployeeDashboardTest < ActiveSupport::TestCase
  subject { EmployeeDashboard.new(build(:user)) }
  should delegate_method(:percentage).to(:document_compliance).with_prefix(true)
  should delegate_method(:percentage).to(:training_compliance).with_prefix(true)

  test '#when_show_compliance_stats_for_offices' do
    user = build(:user, :employee)
    subject = EmployeeDashboard.new(user)
    block_called = false

    subject.when_show_compliance_stats_for_offices do
      block_called = true
    end

    assert_equal false, block_called
  end

  describe '#when_employee_record_exists' do
    test 'when record exists' do
      employee_record = employee_records(:ed)
      subject = EmployeeDashboard.new(employee_record.user)
      block_called = false

      subject.when_employee_record_exists do
        block_called = true
      end

      assert_equal true, block_called
    end

    test 'when no record exists' do
      user = users(:employee_with_no_employee_record)
      subject = EmployeeDashboard.new(user)
      block_called = false

      subject.when_employee_record_exists do
        block_called = true
      end

      assert_equal false, block_called
    end
  end

  describe '#when_no_employee_record_exists' do
    test 'when record exists' do
      employee_record = employee_records(:ed)
      subject = EmployeeDashboard.new(employee_record.user)
      block_called = false

      subject.when_no_employee_record_exists do
        block_called = true
      end

      assert_equal false, block_called
    end

    test 'when no record exists' do
      user = build(:user, :employee)
      user.stubs(:employee_record).returns(nil)
      subject = EmployeeDashboard.new(user)
      block_called = false

      subject.when_no_employee_record_exists do
        block_called = true
      end

      assert_equal true, block_called
    end
  end

  test '#new_employee_record_form' do
    user = users(:employee)
    subject = EmployeeDashboard.new(user)

    assert_instance_of EmployeeRecordForm, subject.new_employee_record_form
  end

  test '#employee_record_presenter' do
    user = users(:employee)
    subject = EmployeeDashboard.new(user)

    assert_instance_of EmployeeRecordPresenter, subject.employee_record_presenter
  end
end
