require 'test_helper'
require_relative '../models/concerns/common_employee_note_validation_tests'

class EmployeeNoteFormTest < ActiveSupport::TestCase
  include CommonEmployeeNoteValidationTests

  setup do
    @employee_record = employee_records(:ed)
  end

  test 'validation sanity check' do
    form = EmployeeNoteForm.new
    assert_equal false, form.valid?
  end

  test '#employee_notes_path' do
    subject = EmployeeNoteForm.new.with_context(employee_record: @employee_record)

    result = subject.employee_notes_path

    assert_equal "/employee_records/#{@employee_record.id}/employee_notes", result
  end

  test '#employee_record_full_name' do
    subject = EmployeeNoteForm.new.with_context(employee_record: @employee_record)

    result = subject.employee_record_full_name

    assert_equal "#{@employee_record.full_name}", result
  end

  describe '#employee_record' do
    test 'without needed context' do
      subject = EmployeeNoteForm.new

      assert_nil subject.employee_record
    end

    test 'with needed context' do
      subject = EmployeeNoteForm.new.with_context(employee_record: @employee_record)

      refute_nil subject.employee_record
    end
  end

  describe '#curent_account' do
    test 'without needed context' do
      subject = EmployeeNoteForm.new

      assert_nil subject.current_account
    end

    test 'with needed context' do
      subject = EmployeeNoteForm.new.with_context(current_account: @employee_record.account)

      refute_nil subject.current_account
    end
  end
end
