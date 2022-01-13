class ExamGrade
  class EmptyAnswers < StandardError; end
  class EmptyQuestions < StandardError; end
  class InvalidPassingThreshold < StandardError; end

  def initialize(answers, questions, passing_threshold)
    raise EmptyAnswers if answers.to_a.empty?
    raise EmptyQuestions if questions.to_a.empty?
    raise InvalidPassingThreshold if passing_threshold.to_i <= 0

    @answers = answers
    @questions = questions
    @passing_threshold = passing_threshold.to_i
  end

  def passed?
    grade_percentage >= @passing_threshold
  end

  def grade_percentage
    ((correct_answers.size.to_f / total_questions.to_f) * 100).ceil
  end

  private

  def total_questions
    @questions.size
  end

  def correct_answers
    @answers.select do |answer|
      question = @questions.find { |q| q.id == answer.question_id }

      question.correct_choice.id == answer.choice_id
    end
  end
end
