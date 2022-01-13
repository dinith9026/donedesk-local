class ReactivateCourse < ApplicationCommand
  def initialize(course)
    @course = course
  end

  def call
    @course.reactivate!
    broadcast(:ok, @course)
  end
end
