require 'test_helper'

class PaymentGatewayTest < ActiveSupport::TestCase
  test '#create_plan' do
    account_plan = build(:plan)

    plan = PaymentGateway.create_plan(account_plan)

    assert_match(/#{account_plan.name}/i, plan.name)
    assert_match(/#{account_plan.id}-#{account_plan.interval}ly/i, plan.id)
    assert_equal(account_plan.interval, plan.interval)
    assert_equal(account_plan.currency, plan.currency)
    assert_equal(account_plan.monthly_price_in_cents, plan.amount)
  end

  test '#create_customer' do
    account = build(:account)

    customer = PaymentGateway.create_customer(account.name, account.owner_email, stripe_card_token)

    assert_match(/#{account.name}/i, customer.description)
    assert_equal(account.owner_email, customer.email)
    assert_equal(1, customer.sources.total_count)
  end

  test '#create_subscription' do
    customer = Stripe::Customer.create(source: stripe_card_token)
    plan = stripe_helper.create_plan

    subscription = PaymentGateway.create_subscription(customer, plan)

    assert_equal(customer.id, subscription.customer)
    assert_equal(plan.id, subscription.plan.id)
  end

  test '#retrieve_subscription' do
    customer = Stripe::Customer.create(source: stripe_card_token)
    plan = stripe_helper.create_plan
    subscription = PaymentGateway.create_subscription(customer, plan)

    result = PaymentGateway.retrieve_subscription(subscription.id)

    assert_equal(plan.id, result.plan.id)
    assert_equal(customer.id, result.customer)
  end

  test '#update_subscription' do
    customer = Stripe::Customer.create(source: stripe_card_token)
    plan = stripe_helper.create_plan
    subscription = PaymentGateway.create_subscription(customer, plan)
    new_plan = stripe_helper.create_plan(id: 'new_plan')

    result = PaymentGateway.update_subscription(subscription, new_plan)

    assert_equal(new_plan.id, result.plan.id)
  end
end
