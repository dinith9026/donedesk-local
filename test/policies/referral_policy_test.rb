require 'test_helper'

class ReferralPolicyTest < PolicyTest
  describe '#create?' do
    test 'for super admin' do
      refute_permit(:create, users(:super_admin), Referral)
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "for #{role}" do
        user = users(role)

        assert_permit(:create, user, Referral)
      end
    end
  end
end
