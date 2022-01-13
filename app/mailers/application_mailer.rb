class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.donedesk.support_email
  layout 'mailer'

  protected

  def support_email
    Rails.configuration.donedesk.support_email
  end
end
