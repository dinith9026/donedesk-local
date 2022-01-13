require 'test_helper'

class ChoiceFormTest < ActiveSupport::TestCase
  should validate_presence_of(:answer)
end
