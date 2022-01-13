class PaymentGateway
  class CardError < StandardError; end

  def self.create_plan(plan)
    Stripe::Plan.create(
      name: plan.name,
      id: plan.stripe_plan_id,
      interval: plan.interval,
      currency: plan.currency,
      amount: plan.monthly_price_in_cents
    )
  end

  def self.create_customer(description, email, source)
    Stripe::Customer.create(
      description: description,
      email: email,
      source: source
    )
  rescue Stripe::CardError => e
    raise PaymentGateway::CardError, e.message
  end

  def self.create_subscription(customer, plan)
    Stripe::Subscription.create(
      customer: customer.id,
      plan: plan.id
    )
  rescue Stripe::CardError => e
    raise PaymentGateway::CardError, e.message
  end

  def self.retrieve_subscription(id)
    Stripe::Subscription.retrieve(id)
  end

  def self.retrieve_plan(id)
    Stripe::Plan.retrieve(id)
  end

  def self.update_subscription(subscription, new_plan)
    subscription.plan = new_plan.id
    subscription.prorate = false
    subscription.save
  end
end
