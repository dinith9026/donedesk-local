require 'test_helper'

class InquiriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account_owner = users(:account_owner)
  end

  test '#insurance' do
    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      post insurance_quote_requests_path(as: @account_owner),
        params: { files: files, message: 'The message' }
    end
    assert_response :success
  end

  test '#payroll' do
    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      post payroll_requests_path(as: @account_owner), params: payroll_params
    end
    assert_response :redirect
    assert_redirected_to payroll_page_path
    refute_nil flash[:success]
  end

  test '#background_check' do
    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      post background_check_requests_path(as: @account_owner),
        params: background_check_params
    end
    assert_response :redirect
    assert_redirected_to background_check_page_path
    refute_nil flash[:success]
  end

  private

  def files
    {
      0 => fixture_file_upload('test.pdf'),
      1 => fixture_file_upload('test.pdf'),
    }
  end

  def payroll_params
    {
      primary_payroll_contact_name: 'Name',
      phone_number: '555-1234',
      email_address: 'person@example.com',
      current_payroll_provider: 'Paychex',
    }
  end

  def background_check_params
    {
      employer_contact_name: Faker::Name.name,
      employer_phone_number: Faker::PhoneNumber.phone_number,
      employer_email_address: Faker::Internet.safe_email,
      candidate_name: Faker::Name.name,
      candidate_phone_number: Faker::PhoneNumber.phone_number,
      candidate_email_address: Faker::Internet.safe_email,
      background_check: 'Yes',
      drug_test: nil,
    }
  end
end
