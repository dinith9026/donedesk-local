require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  setup do
    @course = courses(:oceanview_handbook)
  end

  test 'when max allowed questions is reached' do
    (Course::MAX_ALLOWED_QUESTIONS - @course.questions.count).times do
      create(:question, course_id: @course.id)
    end

    assert_raises ActiveRecord::RecordInvalid do
      Question.create!(course_id: @course.id)
    end
  end

  test 'when there is more than one correct choice' do
    choices = [
      Choice.new(attributes_for(:choice, is_correct: true)),
      Choice.new(attributes_for(:choice, is_correct: true)),
    ]

    assert_raises ActiveRecord::RecordInvalid do
      Question.create!(valid_attrs.merge(choices: choices))
    end
  end

  private

  def valid_attrs
    attributes_for(:question, course_id: @course.id, choices: attributes_for_list(:choice, 2))
  end

  test '#correct_choice' do
    wrong_choice = build(:choice, is_correct: false)
    correct_choice = build(:choice, is_correct: true)
    question = build(:question, choices: [wrong_choice, correct_choice])

    assert_equal correct_choice, question.correct_choice
  end
end
