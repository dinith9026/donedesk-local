require 'test_helper'

class ExamAnswersTest < ActiveSupport::TestCase
  test '.from_params' do
    question_id = SecureRandom.uuid
    choice_id = SecureRandom.uuid
    params = {
      "0" => { question_id: question_id, choice_id: choice_id }
    }

    rails_params = ActionController::Parameters.new(params)

    result = ExamAnswers.from_params(rails_params)

    assert_equal question_id, result.first.question_id
    assert_equal choice_id, result.first.choice_id
  end
end
