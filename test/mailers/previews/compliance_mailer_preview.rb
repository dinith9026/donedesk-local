# Preview all emails at http://localhost:3000/rails/mailers
class ComplianceMailerPreview < ActionMailer::Preview
  def monthly_account_summary
    account = Account.find_by(name: 'Oceanview Dental')
    summary = AccountComplianceSummary.new(account)

    month = 'December'

    ComplianceMailer.monthly_account_summary(account.owner, month, summary)
  end

  def monthly_account_summary_congrats
    summary = AccountComplianceSummary.new(Account.new)

    month = 'December'

    ComplianceMailer.monthly_account_summary(User.first, month, summary)
  end

  def weekly_employee_summary
    employee_record = EmployeeRecord.find_by(first_name: 'Ed')
    summary = EmployeeComplianceSummary.new(employee_record)

    ComplianceMailer.weekly_employee_summary(employee_record.user, '2019-01-01', summary)
  end

  def weekly_employee_summary_congrats
    summary = EmployeeComplianceSummary.new(EmployeeRecord.new)

    ComplianceMailer.weekly_employee_summary(User.first, '2019-01-01', summary)
  end
end
