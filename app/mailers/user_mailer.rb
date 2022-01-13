class UserMailer < ApplicationMailer
  layout 'mailer'

  def employee_invite_email(user)
    @user = user
    @assigned_tracks = user.employee_record.present? ? user.employee_record.assigned_tracks : []

    mail(to: @user.email, subject: "Invite: #{user.account.name} DoneDesk")
  end
end
