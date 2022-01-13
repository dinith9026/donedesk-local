require 'test_helper'

class EmployeeRecordsPresenterTest < ActiveSupport::TestCase
  describe '#when_employee_records_pending' do
    test 'when records are pending' do
      account = Account.new
      account.stubs(:pending_employee_records).returns([1])
      subject =
        EmployeeRecordsPresenter
        .new([], nil)
        .with_context(current_account: account)
      block_called = false

      subject.when_employee_records_pending do
        block_called = true
      end

      assert_equal true, block_called
    end

    test 'when NO records are pending' do
      account = Account.new
      account.stubs(:pending_employee_records).returns([])
      subject =
        EmployeeRecordsPresenter
        .new([], nil)
        .with_context(current_account: account)
      block_called = false

      subject.when_employee_records_pending do
        block_called = true
      end

      assert_equal false, block_called
    end
  end

  test '#active' do
    account = Account.new
    account.stubs(:active_employee_records).returns(1)
    subject =
      EmployeeRecordsPresenter
      .new([], nil)
      .with_context(current_account: account)

    subject.active

  end

  test '#invites_remaining' do
    account = Account.new
    account.stubs(:invites_remaining).returns(0)
    subject =
      EmployeeRecordsPresenter
      .new([], nil)
      .with_context(current_account: account)

    subject.invites_remaining

  end

  test 'paths' do
    employee_record = EmployeeRecord.new(id: 1)

    subject = EmployeeRecordsPresenter.new([employee_record], nil)

    assert_equal '/employee_records/new', subject.new_path
  end
end
