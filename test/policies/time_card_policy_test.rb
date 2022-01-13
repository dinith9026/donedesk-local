require 'test_helper'

class TimeCardPolicyTest < PolicyTest
  describe '#index?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      test "as a #{role}" do
        refute_permit(:index, users(role), TimeCard)
      end
    end

    test 'as an employee' do
      assert_permit(:index, users(:employee), TimeCard)
    end
  end
end
