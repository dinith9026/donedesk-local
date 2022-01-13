class CurrentAccountController < ApplicationController
  def update
    authorize CurrentAccount
    CurrentAccount.set(account, session)
    redirect_to offices_url
  end

  private

  def account
    Account.find_by!(name: params[:current_account_name])
  end
end
