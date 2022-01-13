require 'test_helper'

class UserPresenterTest < ActiveSupport::TestCase
  subject { UserPresenter.new(nil, nil) }
  should delegate_method(:full_name).to(:user)
  should delegate_method(:email).to(:user)
  should delegate_method(:send_compliance_summary_email).to(:user)

  describe '#when_password_reset_token_present' do
    test 'when present' do
      user = users(:employee)
      user.confirmation_token = 'present'
      subject = UserPresenter.new(user, policy_stub)
      block_called = false

      subject.when_password_reset_token_present { block_called = true }

      assert_equal true, block_called
    end

    test 'when not present' do
      user = users(:employee)
      user.confirmation_token = nil
      subject = UserPresenter.new(user, policy_stub)
      block_called = false

      subject.when_password_reset_token_present { block_called = true }

      assert_equal false, block_called
    end
  end

  test '#password_reset_url' do
    user = users(:employee)
    user.confirmation_token = 'token'
    subject = UserPresenter.new(user, policy_stub)
    host = Rails.configuration.donedesk.host
    expected_url = "http://#{host}/users/#{user.id}/password/edit?token=token"

    result = subject.password_reset_url

    assert_equal expected_url, result
  end

  describe 'two_factor_enabled?' do
    test 'when enabled' do
      user = users(:employee)
      user.two_factor_enabled = true
      subject = UserPresenter.new(user, policy_stub)

      result = subject.two_factor_enabled?

      assert_equal 'Yes', result
    end

    test 'when disabled' do
      user = users(:employee)
      user.two_factor_enabled = false
      subject = UserPresenter.new(user, policy_stub)

      result = subject.two_factor_enabled?

      assert_equal 'No', result
    end

    test 'when not set' do
      user = users(:employee)
      user.two_factor_enabled = nil
      subject = UserPresenter.new(user, policy_stub)

      result = subject.two_factor_enabled?

      assert_equal 'Not Set', result
    end
  end

  describe '#parent_two_factor_setting' do
    test 'when user has an account with 2FA enabled' do
      account = Account.new(two_factor_enabled: true)
      user = User.new(account: account)
      subject = UserPresenter.new(user, policy_stub)

      result = subject.parent_two_factor_setting

      assert_equal '(Account Default: Yes)', result
    end

    test 'when user has an account with 2FA disabled' do
      account = Account.new(two_factor_enabled: false)
      user = User.new(account: account)
      subject = UserPresenter.new(user, policy_stub)

      result = subject.parent_two_factor_setting

      assert_equal '(Account Default: No)', result
    end

    test 'when user has NO account' do
      user = User.new
      subject = UserPresenter.new(user, policy_stub)

      result = subject.parent_two_factor_setting

      assert_equal '(System Default: Yes)', result
    end
  end

  describe '#when_two_factor_required' do
    test 'when required' do
      user = User.new
      user.stubs(:two_factor_required?).returns(true)
      subject = UserPresenter.new(user, policy_stub)
      block_called = false

      subject.when_two_factor_required { block_called = true }

      assert_equal true, block_called
    end

    test 'when NOT required' do
      user = User.new
      user.stubs(:two_factor_required?).returns(false)
      subject = UserPresenter.new(user, policy_stub)
      block_called = false

      subject.when_two_factor_required { block_called = true }

      assert_equal false, block_called
    end
  end

  describe 'edit_path' do
    test 'when user is NOT current_user' do
      user = users(:employee)
      subject = UserPresenter.new(user, policy_stub)

      assert_equal "/users/#{user.id}/edit", subject.edit_path
    end

    test 'when user is current_user' do
      user = users(:employee)
      subject = UserPresenter.new(user, policy_stub(user))

      assert_equal "/profile/edit", subject.edit_path
    end
  end
end
