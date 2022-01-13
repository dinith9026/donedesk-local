class UserPresenter < ModelPresenter
  presents :user

  delegate :full_name, :email, :send_compliance_summary_email, to: :user

  def when_password_reset_token_present(&block)
    if user.confirmation_token.present?
      yield
    end
  end

  def password_reset_url
    edit_user_password_url(
      user,
      token: user.confirmation_token.html_safe,
      host: Rails.configuration.donedesk.host
    )
  end

  def two_factor_enabled?
    if user.two_factor_enabled === true
      'Yes'
    elsif user.two_factor_enabled === false
      'No'
    else
      'Not Set'
    end
  end

  def parent_two_factor_setting
    if user.account.present?
     "(Account Default: #{user.account_two_factor_enabled? ? 'Yes' : 'No'})"
    else
     "(System Default: Yes)"
    end
  end

  def when_two_factor_required(&block)
    if user.two_factor_required?
      yield
    end
  end

  def when_two_factor_not_required(&block)
    if !user.two_factor_required?
      yield
    end
  end

  def edit_path
    if current_user == user
      edit_profile_path
    else
      edit_user_path(user)
    end
  end
end
