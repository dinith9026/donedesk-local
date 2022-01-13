class AccountPresenter < ModelPresenter
  presents :account
  delegate :name, :plan_monthly_price_in_cents, :plan_max_employees, :pending_invites, :plan,
    :owner_email, :invite_token, :owner_full_name, :active?, :deactivated?, to: :account

  def created_datetime
    account.created_at.in_time_zone('Central Time (US & Canada)').strftime('%Y-%m-%d %l:%M %p %Z')
  end

  def updated_datetime
    account.updated_at.in_time_zone('Central Time (US & Canada)').strftime('%Y-%m-%d %l:%M %p %Z')
  end

  def when_invites_pending(&block)
    if pending_invites.count > 0
      yield
    end
  end

  def when_show_plan_alert(&block)
    if account.plan_max_employees_reached?
      yield
    end
  end

  def time_tracking?
    if account.time_tracking?
      'Yes'
    else
      'No'
    end
  end

  def two_factor_enabled?
    if account.two_factor_enabled?
      'Yes'
    else
      'No'
    end
  end

  def registration_status
    {
      true => 'Registered',
      false => 'Pending Registration',
    }.fetch(account.registered?, 'Error')
  end

  def offices
    OfficesPresenter.new(account.offices, current_user)
  end

  def office_count
    account.office_count
  end

  def show_path
    account_path(account)
  end

  def edit_path
    edit_account_path(account)
  end

  def reinvite_path
    reinvite_account_path(account)
  end

  def new_plan_path
    new_account_plan_path(account)
  end

  def new_office_path
    new_account_office_path(account)
  end

  def reactivate_path
    reactivate_account_path(account)
  end

  def switch_account_path
    current_account_path(current_account_name: account.name)
  end
end
