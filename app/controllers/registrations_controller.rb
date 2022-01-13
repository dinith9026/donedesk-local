class RegistrationsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  before_action :skip_authorization, only: [:new, :create]

  layout 'simple'

  def new
    @account = find_account
    @form = RegistrationForm.new
  end

  def create
    @account = find_account
    @form = RegistrationForm.from_params(registration_params)

    CompleteRegistration.call(@form, @account) do
      on(:ok)         { |account| sign_in_and_redirect_to_dashboard_for(account.owner) }
      on(:invalid)    { render :new }
      on(:card_error) { |card_error| set_flash_error_and_render(:new, card_error) }
    end
  end

  private

  def registration_params
    params.require(:registration)
          .permit(:password, :password_confirmation, :terms, :stripe_token)
  end

  def find_account
    FindAccountByInviteToken.new(params[:invite_token]).query
  end

  def sign_in_and_redirect_to_dashboard_for(owner)
    sign_in owner
    redirect_to dashboard_url, flash: { success: 'Registration complete' }
  end
end
