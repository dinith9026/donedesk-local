require 'test_helper'

class QuestionFormTest < ActiveSupport::TestCase
  should validate_presence_of(:text)

  test 'when no correct choice has been specificed' do
    choices = attributes_for_list(:choice, 2, is_correct: false)

    form = QuestionForm.new(attributes_for(:question, choices: choices))

    assert form.invalid?
    refute_nil form.errors[:base]
    assert_includes form.errors[:base], 'Please specify a correct answer'
  end
end
