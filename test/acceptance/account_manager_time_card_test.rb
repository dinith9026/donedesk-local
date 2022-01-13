require 'test_helper'
require_relative './time_card_tests'

class AccountManagerTimeCardTest < AcceptanceTestCase
  setup do
    @user = users(:account_manager)
  end

  include TimeCardTests
end
