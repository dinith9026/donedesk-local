class QuestionForm < ApplicationForm
  attribute :course_id, String
  attribute :text, String
  attribute :choices, Array[ChoiceForm],
              default: 2.times.map { ChoiceForm.new }

  validates :text, presence: true
  validate :one_correct_choice

  private

  def one_correct_choice
    if choices.select { |c| c.is_correct }.count != 1
      errors.add(:base, 'Please specify a correct answer')
    end
  end
end
