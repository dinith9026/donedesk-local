class AccountOfficesController < ApplicationController
  def new
    account = Account.find(params[:account_id])
    office = account.offices.build
    authorize account, :new_office?
    @form =
      OfficeForm
      .from_model(office)
      .with_policy(policy(office))
      .with_context(current_account: current_account)
  end

  def create
    account = Account.find(params[:account_id])
    office = account.offices.build
    authorize account, :new_office?
    @form =
      OfficeForm
      .from_params(params, account_id: account.id)
      .with_policy(policy(office))
      .with_context(current_account: current_account)

    CreateOffice.call(@form) do
      on(:ok)      { |office| set_flash_success_and_redirect_to(account) }
      on(:invalid) { set_flash_error_and_render(:new) }
    end
  end
end
