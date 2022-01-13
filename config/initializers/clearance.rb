Clearance.configure do |config|
  config.rotate_csrf_on_sign_in = true
  config.routes = false
  config.mailer_sender = Rails.configuration.donedesk.support_email
  config.cookie_expiration = lambda { |cookies| Rails.configuration.session_expiration_in_minutes.minutes.from_now.utc }
  config.cookie_name = 'clearance_token'
  config.sign_in_guards = [
    EmployeeSuspendedGuard,
    EmployeeTerminatedGuard,
    AccountDeactivatedGuard,
  ]
end

Clearance::SessionsController.layout "simple"
Clearance::PasswordsController.layout "simple"
