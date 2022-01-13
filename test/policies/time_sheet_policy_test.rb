require 'test_helper'

class TimeSheetPolicyTest < PolicyTest
  describe '#index?' do
    [:super_admin, :account_owner, :account_manager].each do |role|
      describe "as a #{role}" do
        test 'when account has time tracking' do
          account = Account.new
          account.stubs(:time_tracking).returns(true)
          policy_context = PolicyContext.new(users(role), account)

          assert_permit(:index, policy_context, TimeSheet)
        end

        test' when account does NOT have time tracking' do
          account = Account.new
          account.stubs(:time_tracking).returns(false)
          policy_context = PolicyContext.new(users(role), account)

          refute_permit(:index, policy_context, TimeSheet)
        end
      end
    end

    test 'as an employee' do
      refute_permit(:index, users(:employee), TimeSheet)
    end
  end
end
