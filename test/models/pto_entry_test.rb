require 'test_helper'
require_relative './concerns/common_pto_entry_validation_tests'

class PTOEntryTest < ActiveSupport::TestCase
  setup do
    @subject = PTOEntry
  end

  include CommonPTOEntryValidationTests

  should validate_presence_of(:employee_record)

  describe 'scopes' do
    test '.within' do
      date_range = 1.day.ago..1.day.from_now
      employee_record = employee_records(:ed)
      within = create(
        :pto_entry,
        date: date_range.begin,
        employee_record: employee_record
      )
      not_within = create(
        :pto_entry,
        date: date_range.end + 1.day,
        employee_record: employee_record
      )

      result = PTOEntry.within(date_range)

      assert_includes result, within
      refute_includes result, not_within
    end
  end
end
