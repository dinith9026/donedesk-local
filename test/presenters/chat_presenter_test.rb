require 'test_helper'

class ChatPresenterTest < ActiveSupport::TestCase
  describe '#when_other_user_present' do
    test 'is false' do
      chat = Chat.new(other_user: nil)
      subject = ChatPresenter.new(chat, nil)
      block_called = false

      subject.when_other_user_present { block_called = true }

      assert_equal false, block_called
    end

    test 'is true' do
      chat = Chat.new(other_user: User.new)
      subject = ChatPresenter.new(chat, nil)
      block_called = false

      subject.when_other_user_present { block_called = true }

      assert_equal true, block_called
    end
  end

  describe '#when_other_user_not_present' do
    test 'is false' do
      chat = Chat.new(other_user: User.new)
      subject = ChatPresenter.new(chat, nil)
      block_called = false

      subject.when_other_user_not_present { block_called = true }

      assert_equal false, block_called
    end

    test 'is true' do
      chat = Chat.new(other_user: nil)
      subject = ChatPresenter.new(chat, nil)
      block_called = false

      subject.when_other_user_not_present { block_called = true }

      assert_equal true, block_called
    end
  end

  test '#account_users_json' do
    current_user = users(:employee)
    account_owner = users(:account_owner)
    account_users = [account_owner, current_user]
    chat = Chat.new(current_user: current_user, account_users: account_users)
    subject = ChatPresenter.new(chat, nil)
    expected = [{ label: account_owner.full_name, value: account_owner.id }]

    result = subject.account_users_json

    assert_equal expected.to_json, result
  end
end
