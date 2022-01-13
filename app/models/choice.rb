class Choice < ApplicationRecord
  belongs_to :question

  delegate :course, to: :question, prefix: true

  validate :number_of_choices_within_limit

  private

  def number_of_choices_within_limit
    if question.choice_limit_reached?
      errors.add(:base, "Max allowed choices reached: #{Question::MAX_ALLOWED_CHOICES}")
    end
  end
end
