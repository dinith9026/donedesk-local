class ListQuestionsForCourse < ApplicationQuery
  def initialize(course_id)
    @course_id = course_id
  end

  def query
    Question.where(course_id: @course_id)
  end
end
