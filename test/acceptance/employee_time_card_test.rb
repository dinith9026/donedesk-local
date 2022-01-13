require 'test_helper'
require_relative './time_card_tests'

class EmployeeTimeCardTest < AcceptanceTestCase
  setup do
    @user = users(:employee)
  end

  include TimeCardTests
end
