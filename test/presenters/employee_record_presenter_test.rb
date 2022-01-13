require 'test_helper'

class EmployeeRecordPresenterTest < ActiveSupport::TestCase
  subject { EmployeeRecordPresenter.new(nil, nil) }
  should delegate_method(:emergency_contact_phone).to(:employee_record)
  should delegate_method(:emergency_contact_email).to(:employee_record)
  should delegate_method(:phone).to(:employee_record)
  should delegate_method(:status).to(:employee_record)
  should delegate_method(:has_missing_or_expired_documents_cached?).to(:employee_record)
  should delegate_method(:document_for).to(:employee_record)
  should delegate_method(:id).to(:employee_record)
  should delegate_method(:user_email).to(:employee_record)
  should delegate_method(:employed?).to(:employee_record)
  should delegate_method(:suspended?).to(:employee_record)
  should delegate_method(:terminated?).to(:employee_record)
  should delegate_method(:last_comma_first).to(:employee_record)
  should delegate_method(:user_gravatar_url).to(:employee_record)

  test 'attributes titleized' do
    attrs_to_titleize = [
      :emergency_contact_relationship,
      :emergency_contact_name,
      :title,
      :marital_status,
      :full_name,
      :office_name,
      :employment_type,
    ]
    employee_record = build(:employee_record)

    subject = EmployeeRecordPresenter.new(employee_record, nil)

    attrs_to_titleize.each do |attr|
      assert_equal employee_record.public_send(attr).titleize,
                   subject.public_send(attr),
                   "#{attr} should be titleized but wasnt: #{subject.public_send(attr)}"
    end
  end

  describe '#when_has_login' do
    test 'is false' do
      employee_record = build(:employee_record)
      employee_record.stubs(:has_login?).returns(false)
      subject = EmployeeRecordPresenter.new(employee_record, nil, { show_actions: false })
      block_called = false

      subject.when_has_login { block_called = true }

      assert_equal false, block_called
    end

    test 'is true' do
      employee_record = build(:employee_record)
      employee_record.stubs(:has_login?).returns(true)
      subject = EmployeeRecordPresenter.new(employee_record, nil, { show_actions: false })
      block_called = false

      subject.when_has_login { block_called = true }

      assert_equal true, block_called
    end
  end

  describe '#when_terminated' do
    test 'is false' do
      employee_record = build(:employee_record)
      employee_record.stubs(:terminated?).returns(false)
      subject = EmployeeRecordPresenter.new(employee_record, nil, { show_actions: false })
      block_called = false

      subject.when_terminated { block_called = true }

      assert_equal false, block_called
    end

    test 'is true' do
      employee_record = build(:employee_record)
      employee_record.stubs(:terminated?).returns(true)
      subject = EmployeeRecordPresenter.new(employee_record, nil, { show_actions: false })
      block_called = false

      subject.when_terminated { block_called = true }

      assert_equal true, block_called
    end
  end

  test '#user_presenter' do
    employee_record = employee_records(:ed)
    subject = EmployeeRecordPresenter.new(employee_record, policy_stub)

    result = subject.user_presenter

    assert_kind_of UserPresenter, result
    assert_equal employee_record.user_id, result.id
  end

  describe '#terminated_on' do
    test 'when nil' do
      employee_record = employee_records(:ed)
      employee_record.stubs(:terminated_on).returns(nil)
      subject = EmployeeRecordPresenter.new(employee_record, nil)

      assert_equal '', subject.terminated_on
    end

    test 'when present' do
      employee_record = employee_records(:ed)
      employee_record.stubs(:terminated_on).returns(Time.now.utc)
      subject = EmployeeRecordPresenter.new(employee_record, nil)
      expected = I18n.l(employee_record.terminated_on.to_date, format: :default)

      assert_equal expected, subject.terminated_on
    end
  end


  describe '#hired_on' do
    test 'when nil' do
      employee_record = employee_records(:ed)
      employee_record.stubs(:hired_on).returns(nil)
      subject = EmployeeRecordPresenter.new(employee_record, nil)

      assert_equal '', subject.hired_on
    end

    test 'when present' do
      employee_record = employee_records(:ed)
      employee_record.stubs(:hired_on).returns(Time.now.utc)
      subject = EmployeeRecordPresenter.new(employee_record, nil)
      expected = I18n.l(employee_record.hired_on.to_date, format: :default)

      assert_equal expected, subject.hired_on
    end
  end

  describe '#dob' do
    test 'when dob is NOT nil' do
      employee_record = employee_records(:ed)
      employee_record.stubs(:dob).returns(nil)
      subject = EmployeeRecordPresenter.new(employee_record, nil)

      assert_equal "", subject.dob
    end

    test 'when dob is nil' do
      employee_record = employee_records(:ed)
      subject = EmployeeRecordPresenter.new(employee_record, nil)
      expected = I18n.l(employee_record.dob.to_date, format: :default)

      assert_equal expected, subject.dob
    end
  end

  describe '#address' do
    test 'when address is NOT nil' do
      employee_record = employee_records(:ed)
      employee_record.address = "123 Some St.\nSan Antonio TX 78230"
      subject = EmployeeRecordPresenter.new(employee_record, nil)
      expected = <<~HTML.strip
        <div>123 Some St.
        <br />San Antonio TX 78230</div>
      HTML

      assert_equal expected, subject.address
    end

    test 'when address is nil' do
      employee_record = employee_records(:ed)
      employee_record.address = nil
      subject = EmployeeRecordPresenter.new(employee_record, nil)

      assert_equal '', subject.address
    end
  end

  describe '#documents_status' do
    test 'when missing or expired documents' do
      employee_record_stub = Struct.new(:has_missing_or_expired_documents_cached?).new(true)
      subject = EmployeeRecordPresenter.new(employee_record_stub, nil)

      assert_equal 'Missing/expired documents', subject.documents_status
    end

    test 'when no missing or expired documents' do
      employee_record_stub = Struct.new(:has_missing_or_expired_documents_cached?).new(false)
      subject = EmployeeRecordPresenter.new(employee_record_stub, nil)

      assert_equal 'All documents valid', subject.documents_status
    end
  end

  test '#account_admin' do
    user = users(:account_owner)
    employee_record = build(:employee_record, user: user)
    subject = EmployeeRecordPresenter.new(employee_record, nil)

    assert_equal true, subject.account_admin?
  end

  test '#each_available_document_type' do
    doc_type = build(:document_type)
    employee_record_stub = Struct.new(:available_document_types).new([doc_type])
    block_called = false
    subject = EmployeeRecordPresenter.new(employee_record_stub, policy_stub)

    subject.each_available_document_type do |arg|
      block_called = true
      assert_kind_of DocumentTypePresenter, arg
    end

    assert_equal true, block_called
  end

  test '#assignable_courses' do
    employee_record = employee_records(:ed)
    subject = EmployeeRecordPresenter.new(employee_record, policy_stub)

    result = subject.assignable_courses

    assert_kind_of CoursesPresenter, result
  end

  test '#assignable_tracks' do
    employee_record = employee_records(:ed)
    subject = EmployeeRecordPresenter.new(employee_record, policy_stub)

    result = subject.assignable_tracks

    assert_kind_of TracksPresenter, result
  end

  test '#active_assignments_grouped' do
    employee_record = employee_records(:ed)
    subject = EmployeeRecordPresenter.new(employee_record, policy_stub)

    result = subject.active_assignments_grouped

    assert_includes result.keys, 'Single Courses'
    assert_includes result.keys, 'Oceanview Track 1'
    assert_kind_of AssignmentPresenter, result['Oceanview Track 1'].first
    assert_nil result['Single Courses'].first.maybe_track
    refute_nil result['Oceanview Track 1'].first.maybe_track
  end

  test '#employee_notes' do
    employee_record = employee_records(:ed)
    subject = EmployeeRecordPresenter.new(employee_record, policy_stub)

    result = subject.employee_notes

    assert_kind_of EmployeeNotesPresenter, result
  end

  describe '#when_show_actions' do
    test 'is set to false' do
      employee_record = build(:employee_record)
      block_called = false
      subject = EmployeeRecordPresenter.new(employee_record, nil, { show_actions: false })

      subject.when_show_actions do
        block_called = true
      end

      assert_equal false, block_called
    end

    test 'is not set' do
      employee_record = build(:employee_record)
      block_called = false
      subject = EmployeeRecordPresenter.new(employee_record, nil)

      subject.when_show_actions do
        block_called = true
      end

      assert_equal true, block_called
    end
  end

  test 'paths' do
    employee_stub =
      Struct
      .new(:id, :office, :document_group)
      .new(1, offices(:oceanview_tx), document_groups(:oceanview_default))
    subject = EmployeeRecordPresenter.new(employee_stub, nil)

    refute_nil subject.edit_path
    refute_nil subject.show_path
    refute_nil subject.new_document_path
    refute_nil subject.new_employee_note_path
    refute_nil subject.assignments_path
    refute_nil subject.assigned_tracks_path
    refute_nil subject.suspend_path
    refute_nil subject.unsuspend_path
    refute_nil subject.terminate_path
    refute_nil subject.rehire_path
    refute_nil subject.new_invite_path
    refute_nil subject.office_show_path
    refute_nil subject.document_group_show_path
  end
end
