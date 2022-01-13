class AssignmentAction
  attr_reader :text, :path

  private_class_method :new

  class << self
    include Rails.application.routes.url_helpers

    def from_assignment(assignment, maybe_track)
      if maybe_track.present?
        next_course = maybe_track.next_course_to_take(assignment.employee_record_id)
      end

      track_present_and_incomplete = maybe_track.present? && !maybe_track.completed?(assignment.employee_record_id)
      is_next_course_to_take_in_track = next_course&.id == assignment.course_id

      if track_present_and_incomplete && assignment.new? && !is_next_course_to_take_in_track
        new(nil, nil)
      elsif assignment.new?
        new('Take Course', assignment_path(assignment))
      elsif assignment.passed? && !assignment.expiring_soon?
        new('View Material', assignment_path(assignment))
      elsif assignment.retake_course? || assignment.expired?
        new('Retake Course', assignment_path(assignment))
      else
        new('Retake Exam', new_assignment_exam_path(assignment))
      end
    end
  end

  def initialize(text, path)
    @text = text
    @path = path
  end
end
