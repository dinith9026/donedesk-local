# Preview all emails at http://localhost:3000/rails/mailers/inquiry_mailer
class InquiryMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/inquiry_mailer/insurance_quote_request
  def insurance_quote_request
    account = Account.last
    message = Faker::Lorem.paragraph(8)

    InquiryMailer.insurance_quote_request(account, message)
  end

  def payroll_request
    account = Account.last
    form_data = {
      primary_payroll_contact_name: 'John Doe',
      phone_number: '555-1234',
      email_address: 'person@example.com',
      current_payroll_provider: 'Paychex',
    }

    InquiryMailer.payroll_request(account, form_data)
  end

  def background_check_request
    account = Account.last
    form_data = {
      employer_contact_name: Faker::Name.name,
      employer_phone_number: Faker::PhoneNumber.phone_number,
      employer_email_address: Faker::Internet.safe_email,
      candidate_name: Faker::Name.name,
      candidate_phone_number: Faker::PhoneNumber.phone_number,
      candidate_email_address: Faker::Internet.safe_email,
      background_check: 'Yes',
      drug_test: nil,
    }

    InquiryMailer.background_check_request(account, form_data)
  end
end
