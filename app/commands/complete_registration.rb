class CompleteRegistration < ApplicationCommand
  def initialize(form, account)
    @form = form
    @account = account
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    transaction do
      InitializeBilling.call(@account, @form.stripe_token)

      @account.clear_invite_token!
      @account.update_owner_password(@form.password)

      RegistrationMailer
        .account_owner_welcome_email(@account.owner)
        .deliver_later
    end

    broadcast(:ok, @account)

  rescue PaymentGateway::CardError => e
    @form.stripe_token = nil
    broadcast(:card_error, e.message)
  end
end
