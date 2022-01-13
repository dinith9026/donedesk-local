require 'test_helper'

class AccountOwnerTimeCardTest < AcceptanceTestCase
  test 'does not have a time card' do
    user = users(:account_owner)
    sign_in_with user

    within '.main-menu-header' do
      refute_content 'Time Card'
    end
  end
end
