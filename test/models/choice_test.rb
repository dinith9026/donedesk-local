require 'test_helper'

class ChoiceTest < ActiveSupport::TestCase
  test 'when max allowed choices is reached' do
    question = questions(:for_oceanview_handbook)
    (Question::MAX_ALLOWED_CHOICES- question.choices.count).times do
      create(:choice, question_id: question.id)
    end

    assert_raises ActiveRecord::RecordInvalid do
      Choice.create!(question_id: question.id)
    end
  end
end
