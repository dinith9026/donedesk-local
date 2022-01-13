require 'test_helper'

class EstimatedMonthlyRevenueTest < ActiveSupport::TestCase
  test 'excludes accounts which are deactivated or pending registration' do
    create(:account, :deactivated)
    create(:account, :invited)
    expected_result = Account.all.inject(0) do |sum, a|
      if a.registered? && a.active?
        sum + a.plan.monthly_price
      else
        sum + 0
      end
    end

    actual_result = EstimatedMonthlyRevenue.new.query

    assert_equal expected_result, actual_result
  end
end
