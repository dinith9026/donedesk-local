class ChoiceForm < ApplicationForm
  attribute :question_id, String
  attribute :answer, String
  attribute :is_correct, Boolean, default: false

  validates :answer, presence: true
end
