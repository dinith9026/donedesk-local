class Exam < ApplicationRecord
  attr_accessor :answers

  belongs_to :assignment
  has_one :course, through: :assignment

  delegate :course_questions, :course_title, :course_description,
           :course_passing_threshold_percentage, :employee_record_id,
            to: :assignment
  delegate :account, :is_canned?, to: :course, prefix: true

  def to_s
    passed? ? 'Passed' : 'Failed'
  end

  def grade!(answers, grader = ExamGrade)
    exam_grade =
      grader.new(answers, course_questions, course_passing_threshold_percentage)

    self.passed = exam_grade.passed?
    save!

    self
  end

  def course_is_canned_or_belongs_to_account?(account)
    course_is_canned? || course_account.id == account.id
  end
end
