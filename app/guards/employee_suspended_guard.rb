class EmployeeSuspendedGuard < Clearance::SignInGuard
  def call
    if suspended?
      failure('Your status is suspended.')
    else
      next_guard
    end
  end

  def suspended?
    signed_in? &&
      current_user.employee_record.present? &&
      current_user.employee_record_suspended?
  end
end
