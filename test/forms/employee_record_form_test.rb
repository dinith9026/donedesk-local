require 'test_helper'

class EmployeeRecordFormTest < ActiveSupport::TestCase
  subject { build_form }
  should validate_presence_of(:office_id)
  should validate_presence_of(:first_name)
  should validate_presence_of(:last_name)
  should validate_presence_of(:employment_type)

  describe '#dob_formatted' do
    test 'when from model (editing)' do
      dob = employee_records(:ed).dob
      subject = build_form(dob: dob)
      expected = I18n.l(dob.to_date, format: :default)

      assert_equal expected, subject.dob_formatted
    end

    test 'when from params (creating)' do
      dob = '09/13/2018'
      subject = build_form(dob: dob)
      expected = I18n.l(dob.to_date, format: :default)

      assert_equal expected, subject.dob_formatted
    end
  end

  describe '#hired_on_formatted' do
    test 'when from model (editing)' do
      hired_on = employee_records(:ed).hired_on
      subject = build_form(hired_on: hired_on)
      expected = I18n.l(hired_on.to_date, format: :default)

      assert_equal expected, subject.hired_on_formatted
    end

    test 'when from params (creating)' do
      hired_on = '09/13/2018'
      subject = build_form(hired_on: hired_on)
      expected = I18n.l(hired_on.to_date, format: :default)

      assert_equal expected, subject.hired_on_formatted
    end
  end

  describe '#terminated_on_formatted' do
    test 'when from model (editing)' do
      terminated_on = employee_records(:with_terminated_status_and_no_assigned_courses).terminated_on
      subject = build_form(terminated_on: terminated_on)
      expected = I18n.l(terminated_on.to_date, format: :default)

      assert_equal expected, subject.terminated_on_formatted
    end

    test 'when from params (creating)' do
      terminated_on = '09/13/2018'
      subject = build_form(terminated_on: terminated_on)
      expected = I18n.l(terminated_on.to_date, format: :default)

      assert_equal expected, subject.terminated_on_formatted
    end
  end

  describe 'document_group_id validation' do
    test 'when document_group_id is editable' do
      subject = build_form

      subject.valid?

      assert_equal ["can't be blank"], subject.errors.messages[:document_group_id]
    end
  end

  private

  def build_form(attrs = {})
    EmployeeRecordForm.new(attrs).with_policy(policy)
  end

  def policy(user = nil, record = nil)
    EmployeeRecordPolicy.new(user || users(:account_manager), record || EmployeeRecord.new)
  end
end
