require 'test_helper'

module BaseAccountFormTest
  def self.extended(base)
    base.tests
  end

  def tests
    should validate_presence_of(:name)

    test 'when name is already taken for the account' do
      existing_account = accounts(:oceanview_dental)

      form = BaseAccountForm.new(name: existing_account.name)

      assert form.invalid?
      assert_includes form.errors[:name], 'already taken'
    end

    describe '#when_account_is_new' do
      test 'when record is new' do
        subject = BaseAccountForm.new
        block_called = false

        subject.when_account_is_new do
          block_called = true
        end

        assert_equal true, block_called
      end

      test 'when record is not new' do
        subject = BaseAccountForm.new(id: SecureRandom.hex)
        block_called = false

        subject.when_account_is_new do
          block_called = true
        end

        assert_equal false, block_called
      end
    end
  end
end
