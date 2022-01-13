require 'test_helper'

class ChatPolicyTest < PolicyTest
  describe '#show?' do
    test 'as a super admin' do
      refute_permit(:show, users(:super_admin), Chat)
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as a #{role}" do
        refute_permit(:show, users(role), Chat)
      end
    end
  end
end
