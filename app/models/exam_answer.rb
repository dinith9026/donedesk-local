class ExamAnswer
  attr_reader :question_id, :choice_id

  def initialize(question_id, choice_id)
    @question_id = question_id
    @choice_id = choice_id
  end
end
