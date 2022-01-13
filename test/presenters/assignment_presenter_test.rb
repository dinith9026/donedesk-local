require 'test_helper'

class AssignmentPresenterTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  subject { AssignmentPresenter.new(nil, nil) }
  should delegate_method(:course_title).to(:assignment)
  should delegate_method(:course_description).to(:assignment)
  should delegate_method(:course_material_type).to(:assignment)
  should delegate_method(:course_material_url).to(:assignment)
  should delegate_method(:state).to(:assignment)
  should delegate_method(:employee_record_full_name).to(:assignment)
  should delegate_method(:employee_record_last_comma_first).to(:assignment)

  describe '#due_date_with_days_past_due' do
    test 'when assignment is not expirable and has no due date' do
      course = create(:course, :with_question)
      assignment = create(:assignment, course: course, employee_record: employee_records(:ed))
      assignment.stubs(:expirable?).returns(false)
      assignment.stubs(:due_date).returns(nil)
      subject = AssignmentPresenter.new(assignment, policy_stub)

      assert_nil subject.due_date_with_days_past_due
    end

    test 'when assignment is not expirable and has a due date' do
      due_date = 5.days.from_now.to_date
      assignment = build(:assignment)
      assignment.stubs(:expirable?).returns(false)
      assignment.stubs(:due_date).returns(due_date)
      expected_date = I18n.localize(due_date, format: :default)
      subject = AssignmentPresenter.new(assignment, policy_stub)

      assert_equal "#{expected_date} (5 days)", subject.due_date_with_days_past_due
    end

    test 'when assignment is expiring soon' do
      due_date = 5.days.from_now.to_date
      assignment = build(:assignment)
      assignment.stubs(:expirable?).returns(true)
      assignment.stubs(:expiring_soon?).returns(true)
      assignment.stubs(:due_date).returns(due_date)
      expected_date = I18n.localize(due_date, format: :default)
      subject = AssignmentPresenter.new(assignment, policy_stub)

      assert_equal "#{expected_date} (5 days)", subject.due_date_with_days_past_due
    end

    test 'when assignment expirable and not expiring soon and not expired and has a due date' do
      due_date = 5.days.ago.to_date
      assignment = build(:assignment)
      assignment.stubs(:expirable?).returns(true)
      assignment.stubs(:expiring_soon?).returns(false)
      assignment.stubs(:expired?).returns(false)
      assignment.stubs(:due_date).returns(due_date)
      expected_date = I18n.localize(due_date, format: :default)
      expected = "<span class=\"text-danger\">#{expected_date} (5 days past due)</span>"
      subject = AssignmentPresenter.new(assignment, policy_stub)

      assert_equal expected, subject.due_date_with_days_past_due
    end

    test 'when assignment expirable and not expiring soon and not expired and has no due date' do
      assignment = build(:assignment)
      assignment.stubs(:expirable?).returns(true)
      assignment.stubs(:expiring_soon?).returns(false)
      assignment.stubs(:expired?).returns(false)
      assignment.stubs(:due_date).returns(nil)
      subject = AssignmentPresenter.new(assignment, policy_stub)

      assert_nil subject.due_date_with_days_past_due
    end

    test 'when assignment is expired' do
      due_date = 5.days.ago.to_date
      assignment = build(:assignment)
      assignment.stubs(:expirable?).returns(true)
      assignment.stubs(:expiring_soon?).returns(false)
      assignment.stubs(:expired?).returns(true)
      assignment.stubs(:due_date).returns(due_date)
      expected_date = I18n.localize(due_date, format: :default)
      expected = "<span class=\"text-danger\">#{expected_date} (5 days past due)</span>"
      subject = AssignmentPresenter.new(assignment, policy_stub)

      assert_equal expected, subject.due_date_with_days_past_due
    end

    test 'when assignment is not expirable and has a due date in the future' do
      due_date = 5.days.from_now.to_date
      assignment = build(:assignment)
      assignment.stubs(:expirable?).returns(false)
      assignment.stubs(:due_date).returns(due_date)
      expected_date = I18n.localize(due_date, format: :default)
      subject = AssignmentPresenter.new(assignment, policy_stub)

      assert_equal "#{expected_date} (5 days)", subject.due_date_with_days_past_due
    end

    test 'when assignment is not expirable and has a due date in the past' do
      due_date = 5.days.ago.to_date
      assignment = build(:assignment)
      assignment.stubs(:expirable?).returns(false)
      assignment.stubs(:due_date).returns(due_date)
      expected_date = I18n.localize(due_date, format: :default)
      expected = "<span class=\"text-danger\">#{expected_date} (5 days past due)</span>"
      subject = AssignmentPresenter.new(assignment, policy_stub)

      assert_equal expected, subject.due_date_with_days_past_due
    end

    test 'when assignment is not expirable and has a due date of today' do
      due_date = Date.current
      assignment = build(:assignment)
      assignment.stubs(:expirable?).returns(false)
      assignment.stubs(:due_date).returns(due_date)
      expected_date = I18n.localize(due_date, format: :default)
      subject = AssignmentPresenter.new(assignment, policy_stub)

      assert_equal "#{expected_date} (due today)", subject.due_date_with_days_past_due
    end
  end

  describe '#prevent_fwd_seeking?' do
    test 'when user can take exam' do
      assignment = build(:assignment)
      policy_stub = Struct.new(:take_exam?).new(true)
      subject = AssignmentPresenter.new(assignment, policy_stub)

      assert_equal true, subject.prevent_fwd_seeking?
    end

    test 'when user cannot take exam' do
      assignment = build(:assignment)
      policy_stub = Struct.new(:take_exam?).new(false)
      subject = AssignmentPresenter.new(assignment, policy_stub)

      assert_equal false, subject.prevent_fwd_seeking?
    end
  end

  describe '#show_continue_modal?' do
    test 'when user can take exam' do
      assignment = build(:assignment)
      policy_stub = Struct.new(:take_exam?).new(true)
      subject = AssignmentPresenter.new(assignment, policy_stub)

      assert_equal true, subject.show_continue_modal?
    end

    test 'when user cannot take exam' do
      assignment = build(:assignment)
      policy_stub = Struct.new(:take_exam?).new(false)
      subject = AssignmentPresenter.new(assignment, policy_stub)

      assert_equal false, subject.show_continue_modal?
    end
  end

  describe '#when_course_has_supplements' do
    test 'when false' do
      assignment_stub = Struct.new(:course_supplements).new([])
      subject = AssignmentPresenter.new(assignment_stub, nil)
      block_called = false

      subject.when_course_has_supplements { block_called = true }

      assert_equal false, block_called
    end

    test 'when true' do
      assignment_stub = Struct.new(:course_supplements).new([1])
      subject = AssignmentPresenter.new(assignment_stub, nil)
      block_called = false

      subject.when_course_has_supplements { block_called = true }

      assert_equal true, block_called
    end
  end

  test '#action' do
    assignment = build(:assignment, id: SecureRandom.uuid)
    subject = AssignmentPresenter.new(assignment, nil)
    action_text = nil
    action_path = nil

    subject.action do |text, path|
      action_text = text
      action_path = path
    end

    refute_nil action_text
    refute_nil action_path
  end

  describe '#action_btn_class' do
    test 'when assignment new' do
      assignment_stub = Assignment.new
      assignment_stub.stubs(:new?).returns(true)
      subject = AssignmentPresenter.new(assignment_stub, nil)

      assert_equal 'btn-success', subject.action_btn_class
    end

    test 'when assignment expiring soon' do
      assignment_stub = Assignment.new
      assignment_stub.stubs(:new?).returns(false)
      assignment_stub.stubs(:expiring_soon?).returns(true)
      subject = AssignmentPresenter.new(assignment_stub, nil)

      assert_equal 'btn-warning', subject.action_btn_class
    end

    test 'when assignment expired' do
      assignment_stub = Assignment.new
      assignment_stub.stubs(:new?).returns(false)
      assignment_stub.stubs(:expiring_soon?).returns(false)
      assignment_stub.stubs(:expired?).returns(true)
      subject = AssignmentPresenter.new(assignment_stub, nil)

      assert_equal 'btn-danger', subject.action_btn_class
    end

    test 'when assignment not new and not expiring soon and not expired' do
      assignment_stub = Assignment.new
      assignment_stub.stubs(:new?).returns(false)
      assignment_stub.stubs(:expiring_soon?).returns(false)
      assignment_stub.stubs(:expired?).returns(false)
      subject = AssignmentPresenter.new(assignment_stub, nil)

      assert_equal 'btn-primary', subject.action_btn_class
    end
  end

  describe '#material_content_partial' do
    test 'when content is a PDF' do
      course = build(:course, material_s3_key: 'test.pdf')
      assignment = build(:assignment, course: course)

      subject = AssignmentPresenter.new(assignment, nil)

      assert_equal 'pdf_content', subject.material_content_partial
    end

    test 'when content is not a PDF' do
      course = build(:course, material_s3_key: 'test.mp4')
      assignment = build(:assignment, course: course)

      subject = AssignmentPresenter.new(assignment, nil)

      assert_equal 'video_content', subject.material_content_partial
    end
  end

  describe '#state_tag' do
    test 'when state is new' do
      assignment = build(:assignment, :new)
      subject = AssignmentPresenter.new(assignment, nil)

      result = subject.state_tag

      assert_includes result, 'tag-info'
      assert_includes result, assignment.state
    end

    test 'when state is passed' do
      assignment = build(:assignment, :passed)
      subject = AssignmentPresenter.new(assignment, nil)

      result = subject.state_tag

      assert_includes result, 'tag-success'
      assert_includes result, assignment.state
    end

    test 'when state is failed' do
      assignment = build(:assignment, :failed)
      subject = AssignmentPresenter.new(assignment, nil)

      result = subject.state_tag

      assert_includes result, 'tag-danger'
      assert_includes result, assignment.state
    end

    test 'when state is expired' do
      assignment = build(:assignment, :expired)
      subject = AssignmentPresenter.new(assignment, nil)

      result = subject.state_tag

      assert_includes result, 'tag-danger'
      assert_includes result, assignment.state
    end
  end

  test 'paths and urls' do
    employee_record = build(:employee_record, id: SecureRandom.uuid)
    course = build(:course, id: SecureRandom.uuid)
    assignment = build(
      :assignment,
      id: SecureRandom.uuid,
      employee_record: employee_record,
      course: course)
    subject = AssignmentPresenter.new(assignment, nil)

    refute_nil subject.delete_path
    refute_nil subject.show_path
    refute_nil subject.course_material_url
    refute_nil subject.new_exam_path
    refute_nil subject.download_material_path
    refute_nil subject.download_supplements_path
    refute_nil subject.show_employee_record_path
    refute_nil subject.mark_completed_path
  end
end
