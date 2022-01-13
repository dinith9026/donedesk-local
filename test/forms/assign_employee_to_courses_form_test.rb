require 'test_helper'

class AssignEmployeeToCoursesFormTest < ActiveSupport::TestCase
  describe "validations" do
    test "when course ids is empty" do
      form = AssignEmployeeToCoursesForm.new(course_ids: [])

      assert form.invalid?
      assert_includes form.errors[:base], 'You must select at least one course'
    end
  end
end
