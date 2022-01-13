class DeactivateCourse < ApplicationCommand
  def initialize(course)
    @course = course
  end

  def call
    transaction do
      @course.deactivate!
      @course.courses_tracks.destroy_all if @course.courses_tracks.any?
    end

    broadcast(:ok)
  end
end
