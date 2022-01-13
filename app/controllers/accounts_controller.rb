class AccountsController < ApplicationController
  def index
    authorize Account
    accounts = ListAccounts.new
    @accounts_presenter = AccountsPresenter.new(accounts, current_user)
  end

  def new
    @form = NewAccountForm.new.with_context(document_group_presets: document_group_presets)
    authorize Account
  end

  def create
    @form = NewAccountForm.from_params(account_params_for_create).with_context(document_group_presets: document_group_presets)
    authorize Account

    RegisterAccount.call(@form) do
      on(:ok)      { |acc| set_flash_success_and_redirect_to(acc) }
      on(:invalid) { set_flash_error_and_render(:new) }
    end
  end

  def show
    account = find_account
    authorize account
    @account_presenter = AccountPresenter.new(account, policy(account))
  end

  def edit
    account = find_account
    @form = EditAccountForm.from_model(account)
    authorize account
  end

  def update
    account = find_account
    @form = EditAccountForm.from_model(account)
    @form.attributes = account_params_for_update.to_h
    authorize account

    UpdateAccount.call(@form, account) do
      on(:ok)      { |acc| set_flash_success_and_redirect_to(acc) }
      on(:invalid) { set_flash_error_and_render(:edit) }
    end
  end

  def reinvite
    account = find_account
    authorize account

    AccountsMailer.account_owner_invite(account).deliver_later

    set_flash_success_and_redirect_to(accounts_url)
  end

  def deactivate
    account = find_account
    authorize account

    DeactivateAccount.call(account) do
      on(:ok) do
        message = 'Success! Remember to cancel their Stripe subscription.'
        set_flash_success_and_redirect_to(accounts_url, message)
      end
    end
  end

  def reactivate
    account = find_account
    authorize account

    account.reactivate!
    set_flash_success_and_redirect_to(accounts_url)
  end

  private

  def account_params_for_create
    params
      .require(:account)
      .permit(:name, :time_tracking, :two_factor_enabled,
               plan: [ :monthly_price, :max_employees ],
               user: [ :email, :first_name, :last_name ],
               office: [ :name, :street_address, :address2,
                         :city, :state, :zip, :phone, :time_zone ])
  end

  def account_params_for_update
    params.require(:account).permit(:name, :time_tracking, :two_factor_enabled)
  end

  def find_account
    FindAccount.new(params[:id]).query
  end

  def document_group_presets
    DocumentGroupPreset.for_offices
  end
end
