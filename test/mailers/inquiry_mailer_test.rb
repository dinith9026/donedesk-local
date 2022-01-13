require 'test_helper'

class InquiryMailerTest < ActionMailer::TestCase

  FakeUploadedFile = Struct.new(:original_filename, :tempfile)

  class FakeFileReader
    def read(_)
      ''
    end
  end

  test '#insurance_quote_request' do
    account = accounts(:oceanview_dental)
    file1 = FakeUploadedFile.new('file1.pdf', '/path/to/file1.pdf')
    file2 = FakeUploadedFile.new('file2.pdf', '/path/to/file2.pdf')
    files = {0 => file1, 1 => file2}
    message = 'The message.'
    fake_file_reader = FakeFileReader.new

    email = InquiryMailer.insurance_quote_request(account, message, files, fake_file_reader)

    assert_emails(1) { email.deliver_now }
    assert_equal [Rails.configuration.donedesk.support_email], email.to
    assert_equal "New Insurance Quote Request from: #{account.name}", email.subject
    assert_equal 2, email.attachments.count
    assert_includes email.html_part.body.to_s, message
    assert_includes email.text_part.body.to_s, message
  end

  test '#payroll_request' do
    account = accounts(:oceanview_dental)
    form_data = { email_address: 'person@example.com' }

    email = InquiryMailer.payroll_request(account, form_data)

    assert_emails(1) { email.deliver_now }
    assert_equal [Rails.configuration.donedesk.support_email], email.to
    assert_equal "New Payroll Info Request from: #{account.name}", email.subject
    assert_includes email.html_part.body.to_s, form_data[:email_address]
    assert_includes email.text_part.body.to_s, form_data[:email_address]
  end

  test '#background_check_request' do
    account = accounts(:oceanview_dental)
    form_data = {
      practice_name: 'Very Good Teeth',
      first_name: 'Ron',
      last_name: 'Swanson',
      email_address: 'ron@verygoodteeth.com'
    }

    email = InquiryMailer.background_check_request(account, form_data)

    assert_emails(1) { email.deliver_now }
    assert_equal ['support@awscreeners.com'], email.to
    assert_equal "New AmeriWide Account Request from DoneDesk: #{account.name}", email.subject
    assert_includes email.html_part.body.to_s, form_data[:practice_name]
    assert_includes email.text_part.body.to_s, form_data[:practice_name]
    assert_includes email.html_part.body.to_s, form_data[:first_name]
    assert_includes email.text_part.body.to_s, form_data[:first_name]
    assert_includes email.html_part.body.to_s, form_data[:last_name]
    assert_includes email.text_part.body.to_s, form_data[:last_name]
    assert_includes email.html_part.body.to_s, form_data[:email_address]
    assert_includes email.text_part.body.to_s, form_data[:email_address]
  end
end
