class ReplaceAccountPlan < ApplicationCommand
  def initialize(form, account)
    @form = form
    @account = account
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    transaction do
      @account.destroy_plan!
      new_plan = @account.create_plan!(@form.attributes)

      subscription =
        PaymentGateway.retrieve_subscription(@account.stripe_subscription_id)

      new_stripe_plan = PaymentGateway.create_plan(new_plan)

      PaymentGateway.update_subscription(subscription, new_stripe_plan)
    end

    broadcast(:ok, @account)
  end
end
