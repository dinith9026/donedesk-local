require 'test_helper'

class ReferralTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_presence_of(:email)
end
