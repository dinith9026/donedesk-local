class ExamAnswers
  def self.from_params(params)
    answers = []

    params.each_pair do |k, answer|
      answers << ExamAnswer.new(answer[:question_id], answer[:choice_id])
    end

    answers
  end
end
