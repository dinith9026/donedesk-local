class AssignCourseToEmployeesForm < ApplicationForm
  attribute :course, Course
  attribute :employee_record_ids, Array

  validate :at_least_one_employee, :at_least_one_course_question

  private

  def at_least_one_employee
    if employee_record_ids.reject(&:empty?).empty?
      errors.add(:base, 'You must select at least one employee')
    end
  end

  def at_least_one_course_question
    if course.questions.none?
      errors.add(:base, 'You cannot assign a course with no questions')
    end
  end
end
