require 'test_helper'

class RegistrationFormTest < ActiveSupport::TestCase
  should validate_presence_of(:password)
  should validate_confirmation_of(:password)
  should validate_length_of(:password)
    .is_at_least(DoneDesk::MIN_PASSWORD_LENGTH)
  should validate_acceptance_of(:terms)
  should_not allow_values('NOLOWER1', 'noupper1', 'NoDigits').for(:password)

  describe '#when_payment_already_added' do
    test 'when token empty' do
      subject = RegistrationForm.new(stripe_token: '')
      block_called = false

      subject.when_payment_already_added do
        block_called = true
      end

      assert_equal false, block_called
    end

    test 'when token present' do
      subject = RegistrationForm.new(stripe_token: 'present')
      block_called = false

      subject.when_payment_already_added do
        block_called = true
      end

      assert_equal true, block_called
    end
  end

  describe '#when_payment_required' do
    test 'when token present' do
      subject = RegistrationForm.new(stripe_token: 'present')
      block_called = false

      subject.when_payment_required do
        block_called = true
      end

      assert_equal false, block_called
    end

    test 'when token empty' do
      subject = RegistrationForm.new(stripe_token: '')
      block_called = false

      subject.when_payment_required do
        block_called = true
      end

      assert_equal true, block_called
    end
  end
end
