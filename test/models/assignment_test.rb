require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  describe 'validations' do
    test 'when course has no questions' do
      employee_record = employee_records(:ed)
      course = build(:course, questions: [])
      assignment = Assignment.new(course: course, employee_record: employee_record)

      assignment.valid?

      assert_includes assignment.errors[:base], 'You cannot assign a course with no questions'
    end
  end

  describe 'scopes' do
    test '.for_employed_employees' do
      ed = employee_records(:ed)
      eric = employee_records(:eric)
      mary = employee_records(:mary)

      eric.suspended!
      mary.terminated!

      assignment_for_ed = assignments(:oceanview_handbook_for_employee)
      assignment_for_eric = assignments(:oceanview_handbook_for_eric)
      assignment_for_mary = assignments(:oceanview_handbook_for_account_manager)
      other_assignment = assignments(:brookside_handbook)
      ids = [ed.id, eric.id, mary.id]

      result = Assignment.for_employed_employees(ids)

      assert_includes result, assignment_for_ed
      refute_includes result, assignment_for_eric
      refute_includes result, assignment_for_mary
      refute_includes result, other_assignment
    end
  end

  describe '#due_date' do
    test 'when expirable and passed' do
      course = build(:course, days_due_within: 30)
      assignment = build(:assignment, course: course)
      assignment.stubs(:expirable?).returns(true)
      assignment.stubs(:passed?).returns(true)
      assignment.stubs(:expires_on).returns('expires_on')

      assert_equal 'expires_on', assignment.due_date
    end

    test 'when expirable and not passed and expired' do
      assignment = build(:assignment, course: build(:course))
      assignment.stubs(:expirable?).returns(true)
      assignment.stubs(:passed?).returns(false)
      assignment.stubs(:expired?).returns(true)
      assignment.stubs(:expires_on).returns('expires_on')

      assert_equal 'expires_on', assignment.due_date
    end

    test 'when expirable and not passed and not expired and due within is present on course' do
      course = build(:course, days_due_within: 30)
      assignment = build(:assignment, course: course, created_at: DateTime.current)
      assignment.stubs(:expirable?).returns(true)
      assignment.stubs(:passed?).returns(false)
      assignment.stubs(:expired?).returns(false)

      assert_equal Date.current + 30, assignment.due_date
    end

    test 'when not expirable and not passed and due within is present on course' do
      course = build(:course, days_due_within: 30)
      assignment = build(:assignment, course: course, created_at: DateTime.current)
      assignment.stubs(:passed?).returns(false)

      assert_equal Date.current + 30, assignment.due_date
    end

    test 'when not expirable and passed' do
      assignment = build(:assignment)
      assignment.stubs(:expirable?).returns(false)
      assignment.stubs(:passed?).returns(true)

      assert_nil assignment.due_date
    end

    test 'when not expirable and not passed and due within is not present on course' do
      course = build(:course, days_due_within: nil)
      assignment = build(:assignment, course: course, created_at: DateTime.current)
      assignment.stubs(:passed?).returns(false)

      assert_nil assignment.due_date
    end
  end

  describe '#days_until_due' do
    test 'with no due_date' do
      assignment = build(:assignment)
      assignment.stubs(:due_date).returns(nil)

      assert_nil assignment.days_until_due
    end

    test 'with due_date in past' do
      assignment = build(:assignment)
      assignment.stubs(:due_date).returns(1.day.ago.to_date)

      assert_equal -1, assignment.days_until_due
    end

    test 'with due_date in future' do
      assignment = build(:assignment)
      assignment.stubs(:due_date).returns(1.day.from_now.to_date)

      assert_equal 1, assignment.days_until_due
    end

    test 'with due_date of today' do
      assignment = build(:assignment)
      assignment.stubs(:due_date).returns(Date.current)

      assert_equal 0, assignment.days_until_due
    end
  end

  describe '#course_belongs_to_assigned_track?' do
    test 'when course belongs to a track but track is not assigned to employee' do
      assignment = assignments(:for_course_belonging_to_unassigned_track)

      result = assignment.course_belongs_to_assigned_track?

      assert_equal false, result
    end

    test 'when course belongs to a track and track is assigned to employee' do
      assignment = assignments(:oceanview_handbook_for_employee)

      result = assignment.course_belongs_to_assigned_track?

      assert_equal true, result
    end
  end

  test '#active_tracks' do
    assignment = assignments(:oceanview_handbook_for_employee)

    result = assignment.active_tracks

    assert_includes result, tracks(:for_oceanview)
    refute_includes result, tracks(:for_oceanview2)
    refute_includes result, tracks(:for_oceanview_deactivated)
  end

  describe '#active?' do
    test 'when course is deactivated and employee is not employed' do
      course = courses(:canned_deactivated)
      employee_record = employee_records(:eric)
      employee_record.suspended!
      assignment = create(:assignment, employee_record: employee_record, course: course)

      assert_equal false, assignment.active?
    end

    test 'when course is active and employee is not employed' do
      employee_record = employee_records(:eric)
      employee_record.suspended!
      assignment = assignments(:oceanview_handbook_for_eric)

      assert_equal false, assignment.active?
    end

    test 'when course is deactivated and employee is employed' do
      assert_equal false, assignments(:oceanview_deactived_for_ed).active?
    end

    test 'when course is active and employee is employed' do
      assignment = assignments(:oceanview_handbook_for_eric)

      assert_equal true, assignment.active?
    end
  end

  describe '#exam_takeable?' do
    test 'when passing exam exists' do
      assignment = build(:assignment, :passed)

      assert_equal false, assignment.exam_takeable?
    end

    test 'when no exams have been taken' do
      assignment = build(:assignment, :new)

      assert_equal true, assignment.exam_takeable?
    end

    test 'when no passing exams exist' do
      assignment = build(:assignment, :failed)

      assert_equal true, assignment.exam_takeable?
    end

    test 'when passing exam exists but is expired' do
      assignment = build(:assignment, :expired)

      assert_equal true, assignment.exam_takeable?
    end

    test 'when passing exam exists but is expiring soon' do
      assignment = build(:assignment, :expiring_soon)

      assert_equal true, assignment.exam_takeable?
    end
  end

  describe '#state' do
    test 'when no exam has been taken' do
      subject = build(:assignment, exams: [])

      assert_equal 'new', subject.state
    end

    test 'when an exam has been taken and passed' do
      passed_exam = build(:exam, passed: true)
      subject = build(:assignment, exams: [passed_exam])

      assert_equal 'passed', subject.state
    end

    test 'when exams have been taken but none passed' do
      failed_exam = build(:exam, passed: false)
      subject = build(:assignment, exams: [failed_exam])

      assert_equal 'failed', subject.state
    end

    test 'when an exam has been passed and exceeds course compliance expiration' do
      course = build(:course, compliance_expiration_in_days: 90)
      passed_exam = build(:exam, passed: true, created_at: 91.days.ago)
      subject = build(:assignment, course: course, exams: [passed_exam])

      assert_equal 'expired', subject.state
    end
  end

  describe '#new?' do
    test 'when new' do
      assignment = build(:assignment, :new)

      assert_equal true, assignment.new?
    end

    test 'when not new' do
      assignment = build(:assignment, :passed)

      assert_equal false, assignment.new?
    end
  end

  describe '#passed?' do
    test 'when passed' do
      assignment = build(:assignment, :passed)

      assert_equal true, assignment.passed?
    end

    test 'when passed but expired' do
      assignment = build(:assignment, :expired)

      assert_equal false, assignment.passed?
    end

    test 'when not passed' do
      assignment = build(:assignment, :new)

      assert_equal false, assignment.passed?
    end

    test 'when passed/expired then passed again' do
      employee_record = employee_records(:ed)
      course = create(:course, :expiring, :with_question)
      assignment = create(:assignment, course: course, employee_record: employee_record)

      travel_to(1.day.ago) do
        create(:exam, :passed, assignment: assignment)
      end

      travel_to(91.days.ago) do
        create(:exam, :passed, assignment: assignment)
      end

      assert_equal true, assignment.passed?
    end
  end

  test '#date_passed' do
    passed_exam = build(:exam, created_at: 2.days.ago)
    assignment = build(:assignment, exams: [passed_exam])

    assert_equal passed_exam.created_at.to_date, assignment.date_passed
  end

  describe '#failed?' do
    test 'when failed' do
      assignment = build(:assignment, :failed)

      assert_equal true, assignment.failed?
    end

    test 'when not failed' do
      assignment = build(:assignment, :new)

      assert_equal false, assignment.failed?
    end
  end

  describe '#expirable' do
    test 'when true' do
      course = build(:course, :expiring)
      assignment = build(:assignment, course: course)

      assert_equal true, assignment.expirable?
    end
  end

  describe '#expires_on' do
    test 'when course has no expiration' do
      course = build(:course, compliance_expiration_in_days: 0)
      passed_exam = build(:exam, :passed)
      assignment = build(:assignment, course: course, exams: [passed_exam])

      e = assert_raises Assignment::NotExpirable do
        assignment.expires_on
      end
      assert_equal "Calling `#expires_on` when no expiration exists is not allowed. Use `#expirable?`.", e.message
    end

    test 'when course has expiration' do
      course = build(:course, compliance_expiration_in_days: 90)
      passed_exam = build(:exam, :passed, created_at: 89.days.ago)
      subject = build(:assignment, course: course, exams: [passed_exam])

      assert_equal 1.day.from_now.to_date, subject.expires_on.to_date
    end
  end

  describe '#expired?' do
    test 'when course has expiration but assignment not passed' do
      course = build(:course, :expiring)
      failed_exam = build(:exam, :failed)
      assignment = build(:assignment, course: course, exams: [failed_exam])

      assert_equal false, assignment.expired?
    end

    test 'when days since passed does NOT exceed threshold' do
      course = build(:course, compliance_expiration_in_days: 90)
      passed_exam = build(:exam, :passed, created_at: 89.days.ago)
      subject = build(:assignment, course: course, exams: [passed_exam])

      assert_equal false, subject.expired?
    end

    test 'when days since passed equals threshold' do
      course = build(:course, compliance_expiration_in_days: 90)
      passed_exam = build(:exam, :passed, created_at: 90.days.ago)
      subject = build(:assignment, course: course, exams: [passed_exam])

      assert_equal true, subject.expired?
    end

    test 'when days since passed exceeds threshold' do
      course = build(:course, compliance_expiration_in_days: 90)
      passed_exam = build(:exam, :passed, created_at: 91.days.ago)
      subject = build(:assignment, course: course, exams: [passed_exam])

      assert_equal true, subject.expired?
    end
  end

  describe '#expiring_soon?' do
    test 'when course has no expiration' do
      course = build(:course, compliance_expiration_in_days: 0)
      passed_exam = build(:exam, :passed)
      assignment = build(:assignment, course: course, exams: [passed_exam])

      assert_equal false, assignment.expiring_soon?
    end

    test 'when course has expiration but assignment not passed' do
      course = build(:course, :expiring)
      failed_exam = build(:exam, :failed)
      assignment = build(:assignment, course: course, exams: [failed_exam])

      assert_equal false, assignment.expiring_soon?
    end

    test 'when course has expiration but assignment not taken' do
      course = build(:course, :expiring)
      assignment = build(:assignment, course: course, exams: [])

      assert_equal false, assignment.expiring_soon?
    end

    test 'when assignment already expired' do
      course = build(:course, compliance_expiration_in_days: 90)
      passed_exam = build(:exam, :passed, created_at: 90.days.ago)
      subject = build(:assignment, course: course, exams: [passed_exam])

      assert_equal false, subject.expiring_soon?
    end

    test 'when days since passed is not considered soon' do
      course = build(:course, compliance_expiration_in_days: 90)
      passed_exam = build(:exam, :passed, created_at: 44.days.ago)
      subject = build(:assignment, course: course, exams: [passed_exam])

      assert_equal false, subject.expiring_soon?
    end

    test 'when days since passed equals exact soon threshold' do
      course = build(:course, compliance_expiration_in_days: 90)
      passed_exam = build(:exam, :passed, created_at: 45.days.ago)
      subject = build(:assignment, course: course, exams: [passed_exam])

      assert_equal true, subject.expiring_soon?
    end

    test 'when days since passed exceeds soon threshold' do
      course = build(:course, compliance_expiration_in_days: 90)
      passed_exam = build(:exam, :passed, created_at: 61.days.ago)
      subject = build(:assignment, course: course, exams: [passed_exam])

      assert_equal true, subject.expiring_soon?
    end
  end

  describe '#retake_course?' do
    test 'when max retakes is 0' do
      assignment = build(:assignment, :failed)
      assignment.course.max_test_retakes = 0

      assert_equal true, assignment.retake_course?
    end

    test 'when failed and max retakes NOT reached' do
      assignment = build(:assignment, :failed, with_retakes_remaining: 1)

      assert_equal false, assignment.retake_course?
    end

    test 'when failed and max retakes reached' do
      assignment = build(:assignment, :failed, with_retakes_remaining: 0)

      assert_equal true, assignment.retake_course?
    end

    test "when expiring soon" do
      course = build(:course, compliance_expiration_in_days: 90)
      passed_exam = build(:exam, :passed, created_at: 61.days.ago)
      assignment = build(:assignment, course: course, exams: [passed_exam])

      assert_equal true, assignment.retake_course?
    end
  end
end
