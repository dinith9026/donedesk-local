require 'test_helper'

class CoursePresenterTest < ActiveSupport::TestCase
  subject { CoursePresenter.new(nil, nil) }
  should delegate_method(:title).to(:course)
  should delegate_method(:code).to(:course)
  should delegate_method(:description).to(:course)
  should delegate_method(:max_test_retakes).to(:course)
  should delegate_method(:passing_threshold_percentage).to(:course)
  should delegate_method(:material_file_name).to(:course)
  should delegate_method(:material_type).to(:course)
  should delegate_method(:questions).to(:course)
  should delegate_method(:active?).to(:course)
  should delegate_method(:deactivated?).to(:course)
  should delegate_method(:canned?).to(:course)
  should delegate_method(:custom?).to(:course)

  describe '#status' do
    test 'when active' do
      course = courses(:oceanview_handbook)

      subject = CoursePresenter.new(course, nil)

      assert_equal 'Active', subject.status
    end

    test 'when deactivated' do
      course = courses(:canned_deactivated)

      subject = CoursePresenter.new(course, nil)

      assert_equal 'Deactivated', subject.status
    end
  end

  describe '#when_no_questions_exist' do
    test 'is false' do
      course = Struct.new(:questions).new(['question1'])
      subject = CoursePresenter.new(course, nil)
      block_called = false

      subject.when_no_questions_exist do
        block_called = true
      end

      assert_equal false, block_called
    end

    test 'is true' do
      course = Struct.new(:questions).new([])
      subject = CoursePresenter.new(course, nil)
      block_called = false

      subject.when_no_questions_exist do
        block_called = true
      end

      assert_equal true, block_called
    end
  end

  describe "#states" do
    test "when no states" do
      course = build(:course, states: [])
      subject = CoursePresenter.new(course, nil)

      assert_equal subject.states, "N/A"
    end

    test "when one state" do
      course = build(:course, states: ["TX"])
      subject = CoursePresenter.new(course, nil)

      assert_equal subject.states, "TX"
    end

    test "when more than one state" do
      course = build(:course, states: ["AL", "TX"])
      subject = CoursePresenter.new(course, nil)

      assert_equal subject.states, "AL, TX"
    end
  end

  describe '#supplements_list' do
    test 'when no supplements' do
      course = build(:course, supplements: [])
      subject = CoursePresenter.new(course, nil)

      assert_equal subject.supplements_list, 'N/A'
    end

    test 'when one supplement' do
      course = courses(:canned_with_one_supplement)
      subject = CoursePresenter.new(course, nil)

      assert_equal subject.supplements_list, 'supplement.pdf'
    end

    test 'when more than one supplement' do
      course = courses(:canned_with_multiple_supplements)
      subject = CoursePresenter.new(course, nil)

      assert_equal subject.supplements_list, 'supplement1.pdf, supplement2.pdf'
    end
  end

  test '#unassigned_employees' do
    account = accounts(:oceanview_dental)
    account_offices = account.offices.map(&:name).map(&:titleize)
    course = courses(:oceanview_handbook)
    user = users(:account_owner)
    subject = CoursePresenter.new(course, policy_stub(user))

    result = subject.unassigned_employees(account)

    assert_kind_of EmployeeRecordPresenter, result.first[1].first
    assert_includes account_offices, result.keys.first
  end

  test '#total_assigned' do
    course = courses(:oceanview_handbook)
    account = accounts(:oceanview_dental)
    subject = CoursePresenter.new(course, nil)

    account.stub(:assignments_for_course, [1, 2, 3], [course]) do
      assert_equal 3, subject.total_assigned(account)
    end
  end

  test '#total_passed' do
    course = courses(:oceanview_handbook)
    account = accounts(:oceanview_dental)
    subject = CoursePresenter.new(course, nil)

    account.stub(:passed_assignments_for_course, [1, 2, 3], [course]) do
      assert_equal 3, subject.total_passed(account)
    end
  end

  test '#compliance_expiration_in_days' do
    course = build(:course)
    subject = CoursePresenter.new(course, nil)

    result = subject.compliance_expiration_in_days

    assert_equal course.compliance_expiration_in_days.humanize, result
  end

  test 'paths' do
    course_stub = Struct.new(:id).new(1)
    subject = CoursePresenter.new(course_stub, nil)

    refute_nil subject.show_path
    refute_nil subject.edit_path
    refute_nil subject.preview_path
    refute_nil subject.new_question_path
    refute_nil subject.assignments_path
    refute_nil subject.deactivate_path
    refute_nil subject.reactivate_path
    refute_nil subject.download_supplements_path
  end
end
