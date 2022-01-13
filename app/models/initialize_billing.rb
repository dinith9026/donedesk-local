class InitializeBilling < ApplicationCommand
  def initialize(account, stripe_token)
    @account = account
    @stripe_token = stripe_token
  end

  def call
    stripe_customer = PaymentGateway.create_customer(@account.name, @account.owner_email, @stripe_token)
    stripe_plan = PaymentGateway.create_plan(@account.plan)
    stripe_subscription = PaymentGateway.create_subscription(stripe_customer, stripe_plan)

    @account.update!(
      stripe_subscription_id: stripe_subscription.id,
      stripe_customer_id: stripe_customer.id,
    )
  end
end
