class SessionsController < Clearance::SessionsController
  before_action :skip_authorization
  layout 'simple'

  def create
    @user = find_user

    authed_user = authenticate(params)

    if params[:session][:otp_attempt].present? && session[:otp_user_id]
      authenticate_user_with_otp_two_factor(@user)
    elsif !@user || !@user.two_factor_required? || !authed_user || (@user.two_factor_required? && !@user.two_factor_setup?)
      do_sign_in(authed_user)
    else
      prompt_for_otp_two_factor(authed_user)
    end
  end

  private

  def valid_otp_attempt?(user)
    user.authenticate_otp(params[:session][:otp_attempt])
  end

  def authenticate_user_with_otp_two_factor(user)
    if valid_otp_attempt?(user)
      # Remove any lingering user data from login
      session.delete(:otp_user_id)

      do_sign_in(user)
    else
      flash.now[:alert] = 'Invalid code. Try again.'
      prompt_for_otp_two_factor(user, :unauthorized)
    end
  end

  def prompt_for_otp_two_factor(user, status = :ok)
    @user = user

    session[:otp_user_id] = user.id
    render 'sessions/two_factor', status: status
  end

  def do_sign_in(user)
    sign_in(user) do |status|
      if status.success?
        track_sign_in(user) if user.present?
        redirect_back_or url_after_create
      else
        flash.now.alert = status.failure_message
        render template: "sessions/new", status: :unauthorized
      end
    end
  end

  def find_user
    if session[:otp_user_id]
      User.find(session[:otp_user_id])
    elsif params[:session][:email]
      User.find_by(email: params[:session][:email])
    end
  end

  def track_sign_in(user)
    user.update!(
      sign_in_count: user.sign_in_count + 1,
      last_sign_in_at: Time.current,
      last_sign_in_ip: request.remote_ip,
    )
  end
end
