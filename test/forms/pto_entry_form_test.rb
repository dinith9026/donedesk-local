require 'test_helper'
require_relative '../models/concerns/common_pto_entry_validation_tests'

class PTOEntryFormTest < ActiveSupport::TestCase
  include CommonPTOEntryValidationTests

  describe '#employee_record_full_name' do
    test 'without needed context' do
      subject = PTOEntryForm.new

      assert_raises NoMethodError do
        subject.employee_record_full_name
      end
    end

    test 'with needed context' do
      subject = PTOEntryForm.new.with_context(employee_record: employee_records(:ed))

      refute_nil subject.employee_record_full_name
    end
  end

  describe '#formatted_date' do
    test 'when date is nil' do
      subject = PTOEntryForm.new(date: nil)

      assert_nil subject.formatted_date
    end

    test 'when date is blank' do
      subject = PTOEntryForm.new(date: '')

      assert_nil subject.formatted_date
    end

    test 'when date is valid' do
      subject = PTOEntryForm.new(date: '2018-01-01')

      assert_equal '01/01/2018', subject.formatted_date
    end
  end

  describe '#new_form_action' do
    test 'without needed context' do
      subject = PTOEntryForm.new

      assert_raises NoMethodError do
        subject.new_form_action
      end
    end

    test 'with needed context' do
      employee_record = employee_records(:ed)
      subject = PTOEntryForm.new.with_context(employee_record: employee_record)

      result = subject.new_form_action

      assert_equal "/employee_records/#{employee_record.id}/pto_entries", result
    end
  end

  test '#edit_form_action' do
    pto_entry = pto_entries(:for_oceanview_ed)
    subject = PTOEntryForm.from_model(pto_entry)

    result = subject.edit_form_action

    assert_equal "/pto_entries/#{pto_entry.id}", result
  end
end
