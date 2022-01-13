class PasswordsController < Clearance::PasswordsController
  before_action :skip_authorization
  layout 'simple'

  protected

  def flash_failure_after_update
    flash.now[:notice] = @user.errors.full_messages.join(', ')
  end
end
