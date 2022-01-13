require 'test_helper'

class OfficesUserTest < ActiveSupport::TestCase
  test 'validates user is an account_manager' do
    user = users(:employee)
    office = offices(:oceanview_tx)

    subject = OfficesUser.new(user: user, office: office)

    refute subject.valid?
    assert_includes subject.errors[:user], 'must have the account_manager role'
  end
end
