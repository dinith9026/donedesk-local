class AssignEmployeeToCoursesForm < ApplicationForm
  attribute :course_ids, Array

  validate :at_least_one_course

  private

  def at_least_one_course
    if course_ids.reject(&:empty?).empty?
      errors.add(:base, 'You must select at least one course')
    end
  end
end
