class FindExamForAccount < ApplicationQuery
  def initialize(account, exam_id)
    @account = account
    @exam_id = exam_id
  end

  def query
    exam = Exam.find(@exam_id)

    if exam.course_is_canned_or_belongs_to_account?(@account)
      exam
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
