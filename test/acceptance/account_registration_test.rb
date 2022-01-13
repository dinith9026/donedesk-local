require 'test_helper'

class AccountRegistrationTest < AcceptanceTestCase
  setup do
    @account = accounts(:invited)

    Capybara.default_max_wait_time = ENV['CAPYBARA_DEFAULT_MAX_WAIT_TIME'].to_i || Capybara.default_max_wait_time
    Capybara.current_driver = :chrome
  end

  teardown do
    Capybara.use_default_driver
  end

  test 'successful' do
    visit new_registration_path(invite_token: @account.invite_token)

    page.execute_script "window.testStripeToken = '#{stripe_card_token}';"

    fill_in_and_submit_form

    assert_content 'Registration complete'
  end

  test 'when validation fails but payment was successfully added' do
    visit new_registration_path(invite_token: @account.invite_token)

    fill_in_and_submit_form('mismatched_password')

    assert_content 'Fix Errors'
    assert_content 'Payment method added'
  end

  test 'when validation succeeds but card declined' do
    StripeMock.prepare_card_error(:card_declined, :new_customer)

    visit new_registration_path(invite_token: @account.invite_token)

    fill_in_and_submit_form

    assert_content 'The card was declined'
    assert_content 'Credit or debit card'

    page.execute_script "window.testStripeToken = '#{stripe_card_token}';"

    fill_in_and_submit_form

    assert_content 'Registration complete'
  end

  private

  def stripe_iframe
    find(:xpath, "//iframe[contains(@name, 'privateStripeFrame')]")
  end

  def fill_in_and_submit_form(password = default_password)
    Capybara.within_frame stripe_iframe do
      fill_in 'cardnumber', with: '4242424242424242'
      fill_in 'exp-date', with: "01/#{card_year}"
      fill_in 'cvc', with: '123'
      fill_in 'postal', with: '12345'
    end
    fill_in 'registration_password', with: default_password
    fill_in 'registration_password_confirmation', with: password
    check 'registration_terms'
    click_on 'Submit'
  end

  def card_year
    Date.current.strftime('%y').to_i + 1
  end
end
