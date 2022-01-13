require 'test_helper'

class TimeEntryPresenterTest < ActiveSupport::TestCase
  test '#entry_type' do
    time_entry = build(:time_entry, entry_type: 'clock_in')

    subject = TimeEntryPresenter.new(time_entry, nil)

    assert_equal 'Clock in', subject.entry_type
  end

  test '#occurred_at' do
    time_entry = build(:time_entry, occurred_at: '2017-07-17 09:00:00')

    subject = TimeEntryPresenter.new(time_entry, policy_stub)

    assert_equal '09:00 AM', subject.occurred_at
  end

  test '#occurred_at_in_zone' do
    time_entry = build(:time_entry, occurred_at: '2017-07-17 14:00:00')

    subject = TimeEntryPresenter.new(time_entry, policy_stub)

    assert_equal '09:00 AM CDT', subject.occurred_at_in_zone
  end
end
