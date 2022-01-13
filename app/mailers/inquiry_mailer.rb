class InquiryMailer < ApplicationMailer
  layout 'mailer'

  def insurance_quote_request(account, message, files=[], file_reader = File)
    @account = account
    @owner = account.owner
    @message = message

    unless files.empty?
      files.each_pair do |i, file|
        attachments[file.original_filename] = file_reader.read(file.tempfile)
      end
    end

    mail(
      to: Rails.configuration.donedesk.support_email,
      subject: "New Insurance Quote Request from: #{account.name}"
    )
  end

  def payroll_request(account, form_data)
    @account = account
    @owner = account.owner
    @form_data = form_data

    mail(
      to: Rails.configuration.donedesk.support_email,
      subject: "New Payroll Info Request from: #{account.name}"
    )
  end

  def background_check_request(account, form_data)
    @account = account
    @form_data = form_data

    mail(
      to: 'support@awscreeners.com',
      cc: 'rebecca@practicesecure.com',
      subject: "New AmeriWide Account Request from DoneDesk: #{account.name}"
    )
  end
end
