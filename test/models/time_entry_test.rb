require 'test_helper'
require_relative '../models/concerns/common_time_entry_validation_tests'

class TimeEntryTest < ActiveSupport::TestCase
  setup do
    employee_record = employee_records(:ed)
    clock_in(employee_record, 1.day.ago)

    @subject = TimeEntry.new(
      employee_record: employee_record,
      occurred_at: 1.day.ago,
      entry_type: 'clock_in'
    )
  end

  include CommonTimeEntryValidationTests

  test 'validation sanity check' do
    form = TimeEntry.new
    assert_equal false, form.valid?
  end

  test '#occurred_at_in_zone' do
    time_entry = build(:time_entry, occurred_at: '2017-07-17 14:00:00')

    result = time_entry.occurred_at_in_zone

    assert_equal '2017-07-17 09:00:00 -0500', result.to_s
  end
end
