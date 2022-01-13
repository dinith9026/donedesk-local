# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def employee_invite_email
    employee_user = User.where(role: User.roles[:employee]).first
    employee_user.forgot_password!
    UserMailer.employee_invite_email(employee_user)
  end
end
