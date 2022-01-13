require 'test_helper'

class PTOEntryPresenterTest < ActiveSupport::TestCase
  subject { PTOEntryPresenter.new(nil, nil) }
  should delegate_method(:employee_record_full_name).to(:pto_entry)
  should delegate_method(:hours).to(:pto_entry)

  test '#date' do
    pto_entry = PTOEntry.new(date: '2018-01-01')
    subject = PTOEntryPresenter.new(pto_entry, nil)

    assert_equal '01/01/2018', subject.date
  end
end
