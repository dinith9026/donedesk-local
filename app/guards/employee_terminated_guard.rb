class EmployeeTerminatedGuard < Clearance::SignInGuard
  def call
    if terminated?
      failure('Your status is terminated.')
    else
      next_guard
    end
  end

  def terminated?
    signed_in? &&
      current_user.employee_record.present? &&
      current_user.employee_record_terminated?
  end
end
