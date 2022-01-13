require 'test_helper'

class PlanFormTest < ActiveSupport::TestCase
  should validate_presence_of(:monthly_price)
  should validate_presence_of(:max_employees)
  should_not allow_value('').for(:monthly_price)
  should validate_numericality_of(:monthly_price)
  should validate_numericality_of(:max_employees).is_greater_than(0)
end
