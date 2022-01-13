require 'test_helper'

class TimeEntriesPresenterTest < ActiveSupport::TestCase
  test '#initialize' do
    time_entries = [TimeEntry.new, TimeEntry.new]
    user = users(:account_manager)

    result = TimeEntriesPresenter.new(time_entries, user)

    assert_equal 2, result.count
    assert_respond_to result, :each
  end

  describe '#when_user_can_manage_entries' do
    test 'when false' do
      time_entries = [TimeEntry.new, TimeEntry.new]
      user = users(:employee)
      subject = TimeEntriesPresenter.new(time_entries, user)
      block_called = false

      subject.when_user_can_manage_entries { block_called = true }

      assert_equal false, block_called
    end

    test 'when true' do
      time_entries = [TimeEntry.new, TimeEntry.new]
      user = users(:account_manager)
      subject = TimeEntriesPresenter.new(time_entries, user)
      block_called = false

      subject.when_user_can_manage_entries { block_called = true }

      assert_equal true, block_called
    end
  end

  test 'paths' do
    time_entry = TimeEntry.new(id: 1)

    subject =
      TimeEntriesPresenter
      .new([time_entry], nil)
      .with_context(employee_record: employee_records(:ed))

    refute_nil subject.new_path
  end
end
