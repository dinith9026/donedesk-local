class InquiriesController < ApplicationController
  def insurance
    authorize StaticPage.new

    InquiryMailer.insurance_quote_request(
      current_account,
      params[:message],
      params[:files],
    ).deliver_now
  end

  def payroll
    authorize StaticPage.new

    InquiryMailer.payroll_request(
      current_account,
      payroll_params,
    ).deliver_now

    set_flash_success_and_redirect_to(payroll_page_url, msg)
  end

  def background_check
    authorize StaticPage.new

    InquiryMailer.background_check_request(
      current_account,
      background_check_params,
    ).deliver_now

    set_flash_success_and_redirect_to(background_check_page_url, msg)
  end

  private

  def msg
    'Your message has been sent. Someone will contact you shortly.'
  end

  def payroll_params
    params.permit(:primary_payroll_contact_name, :phone_number,
                  :email_address, :current_payroll_provider)
  end

  def background_check_params
    params.permit(:practice_name, :first_name, :last_name, :email_address)
  end
end
