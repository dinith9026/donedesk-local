class TwoFactorSettingsController < ApplicationController
  skip_before_action :setup_two_factor?
  layout 'simple'

  def new
    authorize current_user, :setup_2fa?
    current_user.generate_two_factor_secret_if_missing!
    render :new
  end

  def create
    authorize current_user, :setup_2fa?

    unless current_user.authenticated?(setup_2fa_params[:password])
      flash.now[:alert] = 'Incorrect password'
      return render :new
    end

    if current_user.authenticate_otp(setup_2fa_params[:code])
      current_user.two_factor_setup!

      flash[:notice] = 'Successfully set up two-factor authentication!'
      redirect_to root_path
    else
      flash.now[:alert] = 'Incorrect code'
      render :new
    end
  end

  private

  def setup_2fa_params
    params.require(:two_fa).permit(:code, :password)
  end
end
