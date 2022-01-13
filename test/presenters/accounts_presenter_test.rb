require 'test_helper'

class AccountsPresenterTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  test 'initialize' do
    accounts = [accounts(:oceanview_dental), accounts(:brookside_dental)]
    user = users(:super_admin)

    result = AccountsPresenter.new(accounts, user)

    assert_equal 2, result.count
    assert_respond_to result, :each
  end

  test '#active' do
    active = build(:account, :active)
    deactivated = build(:account, :deactivated)
    subject = AccountsPresenter.new([active, deactivated], nil)

    result = subject.active

    assert_equal 1, result.count
    assert_equal active.name, result.first.name
  end

  test '#deactivated' do
    active = build(:account, :active)
    deactivated = build(:account, :deactivated)
    subject = AccountsPresenter.new([active, deactivated], nil)

    result = subject.deactivated

    assert_equal 1, result.count
    assert_equal deactivated.name, result.first.name
  end

  test 'paths' do
    account = Account.new(id: 1)

    subject = AccountsPresenter.new(account, nil)

    refute_nil subject.new_path
  end
end
