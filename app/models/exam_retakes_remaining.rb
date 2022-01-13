class ExamRetakesRemaining
  def initialize(max_retakes, total_exams)
    @max_retakes = max_retakes
    @total_exams = total_exams
  end

  def calculate
    if @max_retakes == 0
      0
    elsif @total_exams == 0 || (@total_exams % @max_retakes) == 0
      @max_retakes
    elsif @total_exams < @max_retakes
      @max_retakes - @total_exams
    else
      num_exam_rounds = @total_exams / @max_retakes
      current_exam_round_count = @total_exams - (num_exam_rounds * @max_retakes)

      @max_retakes - current_exam_round_count
    end
  end
end
