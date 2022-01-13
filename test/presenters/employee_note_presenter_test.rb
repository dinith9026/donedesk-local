require 'test_helper'

class EmployeeNotePresenterTest < ActiveSupport::TestCase
  subject { EmployeeNotePresenter.new(nil, nil) }
  should delegate_method(:creator_full_name).to(:employee_note)

  setup do
    @employee_note = create(
      :employee_note,
      employee_record: employee_records(:ed),
      creator: users(:account_manager),
      body: "First line\n\nSecond line"
    )
  end

  test '#html_body' do
    subject = EmployeeNotePresenter.new(@employee_note, nil)

    result = subject.html_body

    assert_equal "<p>First line</p>\n\n<p>Second line</p>", result
  end

  test '#created_on' do
    subject = EmployeeNotePresenter.new(@employee_note, nil)
    expected = I18n.localize(@employee_note.created_at.to_date, format: :default)

    result = subject.created_on

    assert_equal expected, result
  end

end
