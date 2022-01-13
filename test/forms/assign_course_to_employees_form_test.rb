require 'test_helper'

class AssignCourseToEmployeesFormTest < ActiveSupport::TestCase
  describe "validations" do
    test "when employee record ids is empty" do
      course = build(:course, :with_question)
      form = AssignCourseToEmployeesForm.new(course: course, employee_record_ids: [])

      assert form.invalid?
      assert_includes form.errors[:base], 'You must select at least one employee'
    end

    test 'course is assignable' do
      employee_record = employee_records(:ed)
      course = build(:course)
      form = AssignCourseToEmployeesForm.new(course: course, employee_record_ids: [employee_record.id])

      form.invalid?

      assert_includes form.errors[:base], 'You cannot assign a course with no questions'
    end
  end
end
