class Question < ApplicationRecord
  MAX_ALLOWED_CHOICES = 6

  belongs_to :course
  has_many :choices, dependent: :destroy

  validate :number_of_questions_within_limit
  validate :only_one_correct_choice

  def choice_limit_reached?
    choices.count >= MAX_ALLOWED_CHOICES
  end

  def correct_choice
    choices.find { |c| c.is_correct }
  end

  private

  def only_one_correct_choice
    if choices.select { |c| c.is_correct }.size > 1
      errors.add(:base, 'There can only be one correct choice')
    end
  end

  def number_of_questions_within_limit
    if course.question_limit_reached?
      errors.add(:base, "Max allowed questions reached: #{Course::MAX_ALLOWED_QUESTIONS}")
    end
  end
end
