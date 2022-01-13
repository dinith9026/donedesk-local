require 'test_helper'
require_relative './deactivateable_tests'
require_relative './concerns/common_course_validation_tests'

class CourseTest < ActiveSupport::TestCase
  include DeactivateableTests
  include CommonCourseValidationTests

  setup do
    @subject = courses(:oceanview_handbook)
  end

  should delegate_method(:for_employed_employees).to(:assignments).with_prefix

  should validate_presence_of(:material_s3_key)
  should validate_uniqueness_of(:title)
    .scoped_to(:account_id)
    .case_insensitive
    .allow_blank

  test "when states contain invalid state code" do
    form = Course.new(states: ['AZ', 'ZZ'])

    refute form.valid?
    assert_includes form.errors[:states], "contain invalid value(s): ZZ"
  end

  describe "scopes" do
    test "active" do
      result = Course.active

      assert_includes result, courses(:oceanview_handbook)
      assert_includes result, courses(:canned)
      refute_includes result, courses(:canned_deactivated)
    end

    test "canned" do
      result = Course.canned

      assert_includes result, courses(:canned)
      refute_includes result, courses(:oceanview_handbook)
    end

    describe "for_states" do
      test 'with mixed case' do
        course = courses(:with_mixed_case_states)

        result = Course.for_states(['tX'])

        assert_includes result, course
      end

      test 'with no overlap' do
        course = create(:course, account_id: nil, states: ['AL', 'AK'])

        result = Course.for_states(['TX', 'TN'])

        refute_includes result, course
      end

      test 'with some overlap' do
        course = create(:course, account_id: nil, states: ['AL', 'AK', 'AZ'])

        result = Course.for_states(['TX', 'AL', 'AK'])

        assert_includes result, course
      end

      test 'with total overlap' do
        course = create(:course, account_id: nil, states: ['AL', 'AK'])

        result = Course.for_states(['AL', 'AK'])

        assert_includes result, course
      end
    end

    test '.for_account' do
      account_with_offices_in_oh_and_tx = accounts(:oceanview_dental)
      custom = courses(:oceanview_handbook)
      canned_no_states = courses(:canned_no_states)
      canned_for_texas = courses(:canned_for_texas)
      canned_for_ohio = courses(:canned_for_ohio)
      canned_for_utah = courses(:canned_for_utah)

      result = Course.for_account(account_with_offices_in_oh_and_tx)

      assert_includes result, custom
      assert_includes result, canned_no_states
      assert_includes result, canned_for_texas
      assert_includes result, canned_for_ohio
      refute_includes result, canned_for_utah
    end
  end

  test '.unassigned_employees' do
    course = courses(:oceanview_handbook)
    assigned_employee = employee_records(:ed)
    unassigned_employee = employee_records(:with_no_assigned_courses)
    unassigned_and_terminated =
      employee_records(:with_terminated_status_and_no_assigned_courses)

    result = course.unassigned_employees

    refute_includes result, assigned_employee
    refute_includes result, unassigned_and_terminated
    assert_includes result, unassigned_employee
  end

  describe '#supplement_filenames' do
    test 'with no supplements' do
      course = build(:course, supplements: [])
      assert_equal course.supplement_filenames, []
    end

    test 'with supplements' do
      course = courses(:canned_with_multiple_supplements)
      assert_equal course.supplement_filenames, ['supplement1.pdf', 'supplement2.pdf']
    end
  end

  describe '#assignable_for?' do
    test 'when state is invalid' do
      course = Course.new

      assert_raise(State::InvalidCode) { course.assignable_for?('INVALID') }
      assert_raise(State::InvalidCode) { course.assignable_for?(nil) }
    end

    test 'when not active' do
      course = courses(:canned_deactivated)

      assert_equal false, course.assignable_for?('TX')
    end

    test 'when active but has no questions' do
      course = build(:course, questions: [])

      assert_equal false, course.assignable_for?('TX')
    end

    test 'when active with at least one question and not required for any state' do
      course = build(:course, :with_question, states: [])

      assert_equal true, course.assignable_for?('TX')
    end

    test 'when active with at least one question and required for state' do
      course = build(:course, :with_question, states: ['TX'])

      assert_equal true, course.assignable_for?('TX')
      assert_equal true, course.assignable_for?('tX')
      assert_equal false, course.assignable_for?('AL')
    end
  end

  test '#passed_assignments_for_employed_employees' do
    course = courses(:oceanview_handbook)
    assignment_stub = Struct.new(:passed?).new(true)
    employee_record_ids = [1, 2, 3]

    course.stub(:assignments_for_employed_employees, [assignment_stub], [employee_record_ids]) do
      result = course.passed_assignments_for_employed_employees(employee_record_ids)

      assert_equal [assignment_stub], result
    end
  end

  describe '#material_type' do
    test 'when pdf' do
      course = Course.new(material_s3_key: 'file.pdf')

      assert_equal 'pdf', course.material_type
    end

    test 'when mp4 video' do
      course = Course.new(material_s3_key: 'file.mp4')

      assert_equal 'video', course.material_type
    end

    test 'when webm video' do
      course = Course.new(material_s3_key: 'file.webm')

      assert_equal 'video', course.material_type
    end

    test 'when unknown' do
      course = Course.new(material_s3_key: 'file.unknown')

      assert_equal 'unknown', course.material_type
    end

    test 'when unsupported' do
      course = Course.new(material_s3_key: 'file.doc')

      assert_equal 'unsupported', course.material_type
    end
  end

  describe '#has_expiration?' do
    test 'when compliance expiration is set to 0 days' do
      course = build(:course, compliance_expiration_in_days: 0)

      assert_equal false, course.has_expiration?
    end

    test 'when compliance expiration is greater than 0 days' do
      course = build(:course, compliance_expiration_in_days: 90)

      assert_equal true, course.has_expiration?
    end
  end

  describe '#assigned?' do
    test 'when at least one assignment exists' do
      subject = Course.new

      subject.stub :assignments, [1] do
        assert_equal true, subject.assigned?
      end
    end

    test 'when no assignments exist' do
      subject = Course.new

      subject.stub :assignments, [] do
        assert_equal false, subject.assigned?
      end
    end
  end
end
