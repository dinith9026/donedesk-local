class AccountDeactivatedGuard < Clearance::SignInGuard
  def call
    if deactivated?
      failure('Your account is deactivated.')
    else
      next_guard
    end
  end

  def deactivated?
    signed_in? &&
      current_user.account.present? &&
      current_user.account_deactivated?
  end
end
