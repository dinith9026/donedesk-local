class UpdateAccount < ApplicationCommand
  def initialize(form, account)
    @form = form
    @account = account
  end

  def call
    return broadcast(:invalid) if @form.invalid?

    @account.update!(@form.attributes)

    broadcast(:ok, @account)
  end
end
