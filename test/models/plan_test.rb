require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  should validate_numericality_of(:monthly_price).only_integer
  should validate_numericality_of(:max_employees).only_integer

  setup do
    @plan = build(:plan)
  end

  test '#name' do
    assert_equal "#{@plan.max_employees} Employees Plan", @plan.name
  end

  test '#stripe_plan_id' do
    assert_equal "#{@plan.id}-#{@plan.interval}ly", @plan.stripe_plan_id
  end

  test '#interval' do
    assert_equal 'month', @plan.interval
  end

  test '#currency' do
    assert_equal 'usd', @plan.currency
  end

  test '#monthly_price_in_cents' do
    expected = 100 * @plan.monthly_price

    assert_equal expected, @plan.monthly_price_in_cents
  end
end
