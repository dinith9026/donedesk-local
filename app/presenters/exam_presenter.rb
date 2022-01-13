class ExamPresenter < ModelPresenter
  presents :exam

  delegate :course_title, :course_description, to: :exam
  delegate :exam_retakes_remaining, :retake_course?, to: :assignment

  def when_must_retake_course(&block)
    if retake_course?
      yield
    end
  end

  def when_must_retake_exam(&block)
    unless retake_course?
      yield
    end
  end

  def assignment_action(&block)
    assignment_presenter.action(&block)
  end

  def result_partial
    exam.to_s.downcase
  end

  def retake_exam_path
    new_assignment_exam_path(assignment)
  end

  private

  def assignment
    @assignment ||= exam.assignment
  end

  def assignment_presenter
    AssignmentPresenter.new(assignment, nil)
  end
end
