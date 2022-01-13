require 'test_helper'
require_relative '../models/concerns/common_time_entry_validation_tests'

class TimeEntryFormTest < ActiveSupport::TestCase
  setup do
    @employee_record = employee_records(:ed)
    clock_in(@employee_record, 1.day.ago)

    @subject = TimeEntryForm.new(
      employee_record_id: @employee_record.id,
      occurred_at: 1.day.ago,
      entry_type: 'clock_in'
    ).with_context(employee_record: @employee_record)
  end

  include CommonTimeEntryValidationTests

  test 'validation sanity check' do
    form = TimeEntryForm.new
    assert_equal false, form.valid?
  end

  describe '#employee_record_full_name' do
    test 'without needed context' do
      subject = TimeEntryForm.new

      assert_raises NoMethodError do
        subject.employee_record_full_name
      end
    end

    test 'with needed context' do
      subject = TimeEntryForm.new.with_context(employee_record: @employee_record)

      refute_nil subject.employee_record_full_name
    end
  end

  describe '#formatted_occurred_at_in_time_zone' do
    test 'when occurred_at is nil' do
      subject = TimeEntryForm.new(occurred_at: nil)

      assert_nil subject.formatted_occurred_at_in_time_zone
    end

    test 'when occurred_at is blank' do
      subject = TimeEntryForm.new(occurred_at: '')

      assert_nil subject.formatted_occurred_at_in_time_zone
    end

    test 'when occurred_at is a valid string' do
      subject =
        TimeEntryForm
        .new(occurred_at: '01/01/2018 3:00 PM')
        .with_context(employee_record: @employee_record)

      assert_equal '01/01/2018 9:00 AM', subject.formatted_occurred_at_in_time_zone
    end

    test 'when occurred_at is a TimeWithZone' do
      subject =
        TimeEntryForm
        .new(occurred_at: Time.zone.parse('01/01/2018 3:00 PM'))
        .with_context(employee_record: @employee_record)

      assert_equal '01/01/2018 9:00 AM', subject.formatted_occurred_at_in_time_zone
    end
  end

  describe '#new_form_action' do
    test 'without needed context' do
      subject = TimeEntryForm.new

      assert_raises NoMethodError do
        subject.new_form_action
      end
    end

    test 'with needed context' do
      employee_record = employee_records(:ed)
      subject = TimeEntryForm.new.with_context(employee_record: employee_record)

      result = subject.new_form_action

      assert_equal "/employee_records/#{employee_record.id}/time_entries", result
    end
  end

  test '#edit_form_action' do
    time_entry = clock_in(employee_records(:ed), '9:00 AM')
    subject = TimeEntryForm.from_model(time_entry)

    result = subject.edit_form_action

    assert_equal "/time_entries/#{time_entry.id}", result
  end

  describe '#entry_type_changed?' do
    test 'when it has changed' do
      subject = TimeEntryForm.new(entry_type: 'clock_in')
      subject.attributes = { entry_type: 'clock_out' }

      assert_equal true, subject.entry_type_changed?
    end

    test 'when it has NOT changed' do
      subject = TimeEntryForm.new(entry_type: 'clock_in')
      subject.attributes = { entry_type: 'clock_in' }

      assert_equal false, subject.entry_type_changed?
    end
  end
end
