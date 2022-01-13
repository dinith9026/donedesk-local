class ComplianceMailer < ApplicationMailer
  layout 'mailer'

  add_template_helper(ApplicationHelper)

  def monthly_account_summary(user, month, summary)
    @summary = summary
    @month = month

    mail(to: user.email, subject: "Done Desk Compliance Summary for #{@month}")
  end

  def weekly_employee_summary(user, date, summary)
    @summary = summary

    mail(to: user.email, subject: "Done Desk Compliance Summary for #{date}")
  end
end
