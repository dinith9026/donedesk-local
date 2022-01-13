require 'test_helper'

class EmployeeRecordTest < ActiveSupport::TestCase
  should validate_presence_of(:first_name)
  should validate_presence_of(:last_name)
  should validate_presence_of(:office_id)
  should validate_presence_of(:employment_type)

  describe 'scopes' do
    test '.active' do
      employed = employee_records(:ed)
      suspended = employee_records(:eric).suspended!
      terminated = employee_records(:ellen).terminated!

      result = EmployeeRecord.active

      assert_includes result, employed
      refute_includes result, suspended
      refute_includes result, terminated
    end
  end

  describe '#send_compliance_summary_email?' do
    test 'when compliant' do
      employee_record = employee_records(:ed)
      summary = EmployeeComplianceSummary.new(employee_record)
      summary.stubs(:compliant?).returns(true)

      result = employee_record.send_compliance_summary_email?(summary)

      assert_equal false, result
    end

    test 'when not compliant and has no login' do
      employee_record = employee_records(:ed)
      employee_record.update!(user: nil)
      summary = EmployeeComplianceSummary.new(employee_record)
      summary.stubs(:compliant?).returns(false)

      result = employee_record.send_compliance_summary_email?(summary)

      assert_equal false, result
    end

    test 'when not compliant and has a login and setting is off' do
      employee_record = employee_records(:ed)
      employee_record.user.update!(send_compliance_summary_email: false)
      summary = EmployeeComplianceSummary.new(employee_record)
      summary.stubs(:compliant?).returns(false)

      result = employee_record.send_compliance_summary_email?(summary)

      assert_equal false, result
    end

    test 'when not compliant and has a login and setting is on' do
      employee_record = employee_records(:ed)
      employee_record.user.update!(send_compliance_summary_email: true)
      summary = EmployeeComplianceSummary.new(employee_record)
      summary.stubs(:compliant?).returns(false)

      result = employee_record.send_compliance_summary_email?(summary)

      assert_equal true, result
    end
  end

  test '#time_cards_for' do
    employee_record = employee_records(:ed)
    date_from = 1.day.ago.to_date
    date_to = Date.current
    time_card_mock = Minitest::Mock.new
    time_card_mock.expect(:new, nil, [employee_record, date_from])
    time_card_mock.expect(:new, nil, [employee_record, date_to])

    result = employee_record.time_cards_for(date_from..date_to, time_card_mock)

    assert_mock time_card_mock
    assert_equal 2, result.count
  end

  describe '#tracks_time?' do
    test 'when true' do
      office = Office.new
      office.stubs(:tracks_time).returns(true)
      employee_record = EmployeeRecord.new(office: office)

      assert_equal true, employee_record.tracks_time?
    end

    test 'when false' do
      office = Office.new
      office.stubs(:tracks_time).returns(false)
      employee_record = EmployeeRecord.new(office: office)

      assert_equal false, employee_record.tracks_time?
    end
  end

  test '#incomplete_assignments' do
    inactive = Assignment.new
    inactive.stubs(:course_active?).returns(false)
    incomplete = Assignment.new
    incomplete.stubs(:course_active?).returns(true)
    incomplete.stubs(:incomplete?).returns(true)
    completed = Assignment.new
    completed.stubs(:course_active?).returns(true)
    completed.stubs(:incomplete?).returns(false)
    assignments = [incomplete, inactive, completed]
    subject = EmployeeRecord.new
    subject.stubs(:assignments).returns(assignments)

    result = subject.incomplete_assignments

    assert_includes result, incomplete
    refute_includes result, inactive
    refute_includes result, completed
  end

  test '#active_assignments' do
    employee_record = EmployeeRecord.new
    active = Struct.new(:course_active?).new(true)
    not_active = Struct.new(:course_active?).new(false)

    employee_record.stub(:assignments, [active, not_active]) do
      result = employee_record.active_assignments

      assert_includes result, active
      refute_includes result, not_active
    end
  end

  test '#assignable_courses' do
    account = Account.new
    employee_in_tx_office = employee_records(:with_no_assigned_courses)
    assignable = courses(:canned_no_states)
    unassignable = courses(:canned_for_ohio)
    course = courses(:oceanview_handbook)
    already_assigned = assign_course(employee_in_tx_office, course).course

    account.stub(:courses, [assignable, unassignable, already_assigned]) do
      result = employee_in_tx_office.assignable_courses

      assert_includes result, assignable,
        'Assignable course SHOULD be included'
      refute_includes result, unassignable,
        'Unassignable course should NOT be included'
      refute_includes result, already_assigned,
        'Already assigned course should NOT be included'
    end
  end

  test '#assignable_tracks' do
    employee_record = employee_records(:ed)

    result = employee_record.assignable_tracks

    assert_includes result, tracks(:unassigned)
    refute_includes result, tracks(:for_oceanview)
    refute_includes result, tracks(:for_oceanview_deactivated)
  end

  describe '#assign_course!' do
    test 'when course is NOT assignable' do
      employee_record = employee_records(:ed)
      course_from_another_account = courses(:brookside_handbook)
      expected_error_message =
        "`#{course_from_another_account.title}` cannot be assigned to " \
        "`#{employee_record.full_name}`"

      error = assert_raise EmployeeRecord::UnassignableCourse do
        employee_record.assign_course!(course_from_another_account)
      end
      assert_equal expected_error_message, error.message
    end

    test 'when course is assignable' do
      employee_record = employee_records(:with_no_assigned_courses)
      course = courses(:oceanview_handbook)

      result = employee_record.assign_course!(course)

      assert_equal employee_record.id, result.employee_record_id
      assert_equal course.id, result.course_id
    end
  end

  test '#full_name' do
    subject = EmployeeRecord.new(first_name: 'Ron', last_name: 'Swanson')

    result = subject.full_name

    assert_equal 'Ron Swanson', result
  end

  test '#last_comma_first' do
    employee_record = employee_records(:ed)
    expected = "#{employee_record.last_name}, #{employee_record.first_name}"

    result = employee_record.last_comma_first

    assert_equal expected, result
  end

  test '#has_missing_documents?' do
    document_type = build(:document_type, id: SecureRandom.uuid)
    employee_record = build(:employee_record, employee_documents: [])

    result = employee_record.stub(:required_documents, [document_type]) do
      employee_record.has_missing_documents?
    end

    assert_equal true, result
  end

  test '#missing_documents' do
    document_type = build(:document_type, id: SecureRandom.uuid)
    employee_record = build(:employee_record, employee_documents: [])

    result = employee_record.stub(:required_documents, [document_type]) do
      employee_record.missing_documents
    end

    assert_includes result, document_type
  end

  test '#expired_documents' do
    document_type = build(:document_type)
    expirable_document = build(
      :employee_document,
      document: build(
        :document,
        document_type: document_type,
        expires_on: Date.tomorrow
      )
    )
    employee_record = build(:employee_record, employee_documents: [expirable_document])

    result = travel_to 2.days.from_now do
      employee_record.stub(:expirable_documents, [expirable_document]) do
        employee_record.expired_documents
      end
    end

    assert_includes result, expirable_document
  end

  test '#expirable_documents' do
    expirable_document = build(:employee_document, document: build(:document, expires_on: Date.tomorrow))
    unexpirable_document = build(:employee_document, document: build(:document, expires_on: nil))
    employee_record = build(
      :employee_record,
      employee_documents: [expirable_document, unexpirable_document])

    result = employee_record.expirable_documents

    assert_includes result, expirable_document
    refute_includes result, unexpirable_document
  end

  describe '#has_document?' do
    test 'when document does not exist' do
      employee_record = build(:employee_record, employee_documents: [])

      result = employee_record.stub(:document_for, nil) do
        employee_record.has_document?('foo')
      end

      assert_equal false, result
    end

    test 'when document does exist' do
      document_type = build(:document_type)
      employee_document = build(:employee_document, document: build(:document, document_type: document_type))
      employee_record = build(:employee_record, employee_documents: [employee_document])

      result = employee_record.stub(:document_for, [employee_document]) do
        employee_record.has_document?(document_type)
      end

      assert_equal true, result
    end
  end

  test '#document_for' do
    document_type = build(:document_type)
    document = build(:document, document_type: document_type)
    employee_record = build(:employee_record)
    employee_document = build(:employee_document, employee_record: employee_record, document: document)
    employee_record.employee_documents = [employee_document]

    result = employee_record.document_for(document_type)

    assert_equal employee_document, result
  end

  test '#documents_for' do
    employee_record = employee_records(:ed)
    document_type_id = document_types(:w4).id
    document_for_different_type = employee_documents(:oceanview_ed_performance_review)
    older_document = employee_documents(:oceanview_ed_w4)
    newer_document = build(
      :employee_document,
      employee_record: employee_record,
      document: build(:document, document_type_id: document_type_id)
    )
    newer_document.save(validate: false) # By-pass validations for file upload

    result = employee_record.documents_for(document_type_id)

    assert_includes result, older_document
    assert_includes result, newer_document
    assert_equal result.first.id, newer_document.id, "Newest document should be first"
    assert_equal result.last.id, older_document.id, "Oldest document should be last"
    refute_includes result, document_for_different_type
  end

  test '#documents_expiring_soon' do
    expiring_employee_document = build(:employee_document, document: build(:document, expires_on: 7.days.from_now))
    expired_employee_document = build(:employee_document, document: build(:document, expires_on: 7.days.ago))
    unexpirable_employee_document = build(:employee_document, document: build(:document, expires_on: nil))
    employee_documents = [expiring_employee_document, expired_employee_document, unexpirable_employee_document]
    employee_record = build(:employee_record, employee_documents: employee_documents)

    result = employee_record.documents_expiring_soon

    assert_equal 1, result.count
    assert_includes result, expiring_employee_document, 'Expiring employee document should be included'
    refute_includes result, expired_employee_document, 'Expired employee document should NOT be included'
    refute_includes result, unexpirable_employee_document, 'Unexpirable employee document should NOT be included'
  end

  test '#required_documents' do
    employee_record = employee_records(:ed)

    assert employee_record.required_documents
  end

  describe '#current_documents' do
    test 'with single unexpirable document for type' do
      doc_type = document_types(:oceanview_performance_review)
      employee_record = create(:employee_record, office: offices(:oceanview_tx), user: create(:user), document_group: document_groups(:oceanview_default))
      doc = create_doc(employee_record, doc_type, nil, 1.day.ago)

      result = employee_record.current_documents

      assert_includes result, doc
    end

    test 'with single expirable document that is NOT expired' do
      doc_type = document_types(:oceanview_performance_review)
      employee_record = create(:employee_record, office: offices(:oceanview_tx), user: create(:user), document_group: document_groups(:oceanview_default))
      doc = create_doc(employee_record, doc_type, 1.day.from_now, 1.day.ago)

      result = employee_record.current_documents

      assert_includes result, doc
    end

    test 'with single expirable document that is expired' do
      doc_type = document_types(:oceanview_performance_review)
      employee_record = create(:employee_record, office: offices(:oceanview_tx), user: create(:user), document_group: document_groups(:oceanview_default))
      doc = create_doc(employee_record, doc_type, 1.day.from_now, 1.day.ago)

      result = travel_to 2.days.from_now do
        employee_record.current_documents
      end

      assert_includes result, doc
    end

    test 'with multiple documents for type and both have no expiration' do
      doc_type = document_types(:oceanview_performance_review)
      employee_record = create(:employee_record, office: offices(:oceanview_tx), user: create(:user), document_group: document_groups(:oceanview_default))
      newer_doc = create_doc(employee_record, doc_type, nil, 1.day.ago)
      older_doc = create_doc(employee_record, doc_type, nil, 2.days.ago)

      result = employee_record.current_documents

      assert_includes result, newer_doc, 'Newer doc should be included'
      refute_includes result, older_doc, 'Older doc should NOT be included'
    end

    test 'with multiple documents for type and only one has expiration and is NOT expired' do
      doc_type = document_types(:oceanview_performance_review)
      employee_record = create(:employee_record, office: offices(:oceanview_tx), user: create(:user), document_group: document_groups(:oceanview_default))
      newer_doc_with_expiration = create_doc(employee_record, doc_type, 1.day.from_now, 1.day.ago)
      older_doc_without_expiration = create_doc(employee_record, doc_type, nil, 2.days.ago)

      result = employee_record.current_documents

      assert_includes result, newer_doc_with_expiration, 'Newer doc with expiration should be included'
      refute_includes result, older_doc_without_expiration, 'Older doc without expiration should NOT be included'
    end

    test 'with multiple documents for type and only one has expiration and is expired' do
      doc_type = document_types(:oceanview_performance_review)
      employee_record = create(:employee_record, office: offices(:oceanview_tx), user: create(:user), document_group: document_groups(:oceanview_default))
      newer_doc_expired = create_doc(employee_record, doc_type, 1.day.from_now, 1.day.ago, 'expired')
      older_doc_without_expiration = create_doc(employee_record, doc_type, nil, 2.days.ago, 'no expiration')

      result = travel_to 2.days.from_now do
        employee_record.current_documents
      end

      assert_includes result, newer_doc_expired, 'Newer doc expired should be included'
      refute_includes result, older_doc_without_expiration, 'Older doc without expiration should NOT be included'
    end

    test 'with multiple documents where expired doc is older than the other unexpired doc' do
      doc_type = document_types(:oceanview_performance_review)
      employee_record = create(:employee_record, office: offices(:oceanview_tx), user: create(:user), document_group: document_groups(:oceanview_default))
      older_expired_doc = create_doc(employee_record, doc_type, 1.day.from_now, 2.days.ago, 'older expired')
      newer_unexpired_doc = create_doc(employee_record, doc_type, 3.days.from_now, 1.day.ago, 'newer unexpired')

      result = travel_to 2.days.from_now do
        employee_record.current_documents
      end

      assert_includes result, newer_unexpired_doc, 'Newer unexpired doc should be included'
      refute_includes result, older_expired_doc, 'Older expired doc should NOT be included'
    end

    test 'with multiple documents for multiple types where expired doc is newer than the other unexpired doc' do
      cpr = document_types(:cpr_certification)
      osha = document_types(:osha_certification)
      w4 = document_types(:w4)
      employee_record = create(:employee_record, office: offices(:oceanview_tx), user: create(:user), document_group: document_groups(:oceanview_default))
      unexpired_document1 = create_doc(employee_record, cpr, 3.days.from_now, 2.days.ago, 'unexpired 1')
      expired_document1 = create_doc(employee_record, cpr, 1.day.from_now, 1.day.ago, 'expired 1')
      unexpired_document2 = create_doc(employee_record, osha, 3.days.from_now, 2.days.ago, 'unexpired 2')
      expired_document2 = create_doc(employee_record, osha, 1.day.from_now, 1.day.ago, 'expired 2')
      unexpirable_document = create_doc(employee_record, w4)

      result = travel_to 2.days.from_now do
        employee_record.current_documents
      end

      assert_includes result, unexpired_document1, 'Newer document 1 should be included'
      assert_includes result, unexpired_document2, 'Newer document 2 should be included'
      assert_includes result, unexpirable_document, 'Unexpirable document should be included'
      refute_includes result, expired_document1, 'Older document 1 should NOT be included'
      refute_includes result, expired_document2, 'Older document 2 should NOT be included'
    end
  end

  private

  def create_doc(employee_record, document_type, expires_on = nil, created_at = nil, summary = nil)
    document = create(
      :document,
      summary: summary,
      document_type: document_type,
      expires_on: expires_on,
      created_at: created_at
    )

    create(
      :employee_document,
      employee_record: employee_record,
      document: document,
      created_at: created_at
    )
  end
end
