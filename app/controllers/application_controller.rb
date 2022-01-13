class ApplicationController < ActionController::Base
  include TimeZonable
  include SmartBackPath
  include Clearance::Controller
  before_action :require_login, :set_raven_context, :setup_two_factor?

  if Rails.configuration.donedesk.http_basic_auth == "true"
    http_basic_authenticate_with name: DoneDesk::Secrets.http_basic_auth_name,
                                 password: DoneDesk::Secrets.http_basic_auth_password
  end

  include Pundit
  after_action :verify_authorized

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_authenticity_token

  def pundit_user
    PolicyContext.new(current_user, current_account)
  end

  def current_account
    return unless current_user
    @current_account ||= CurrentAccount.load(current_user, session) || Account.new
  end
  helper_method :current_account

  def current_account_list
    @current_account_list ||= ListAccounts.new.query
  end
  helper_method :current_account_list

  def current_account_presenter
    policy = AccountPolicy.new(current_user, current_account)
    AccountPresenter.new(current_account, policy)
  end
  helper_method :current_account_presenter

  def set_flash_success_and_redirect_to(url, message = 'Success!')
    redirect_to url, flash: { success: message }
  end

  def set_flash_error_and_render(template, error = 'Please fix the errors below!')
    flash.now[:error] = error
    render template
  end

  def set_flash_error_and_redirect_to(url, error)
    redirect_to url, flash: { error: error }
  end

  def set_flash_warning_and_redirect_to(url, warning)
    redirect_to url, flash: { warning: warning }
  end

  private

  def user_not_authorized
    flash[:error] = 'You are not authorized to perform that action.'
    redirect_back(fallback_location: dashboard_path)
  end

  def record_not_found
    flash[:error] = 'Record not found.'
    redirect_to '/404'
  end

  def invalid_authenticity_token
    flash[:error] = 'Your session expired. Please sign in.'
    redirect_to sign_in_path
  end

  def set_raven_context
    Raven.user_context(id: session[:current_user]&.id)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def setup_two_factor?
    if current_user && current_user.two_factor_required? && !current_user.two_factor_setup?
      redirect_to new_two_factor_settings_path
    end
  end
end
