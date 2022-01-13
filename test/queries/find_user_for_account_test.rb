require 'test_helper'

class FindUserForAccountTest < ActiveSupport::TestCase
  describe '#query' do
    test 'when user does NOT belong to account' do
      account = accounts(:oceanview_dental)
      user = users(:another_employee)
      subject = FindUserForAccount.new(account, user.id)

      assert_raises ActiveRecord::RecordNotFound do
        subject.query
      end
    end

    test 'when user belongs to account' do
      account = accounts(:oceanview_dental)
      user = users(:employee)
      subject = FindUserForAccount.new(account, user.id)

      result = subject.query

      assert_equal user, result
    end
  end
end
