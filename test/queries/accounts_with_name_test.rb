require 'test_helper'

class AccountsWithNameTest < ActiveSupport::TestCase
  test 'when name is case-sensitive' do
    name = 'TEST'
    account = create(:account, name: name)

    result = AccountsWithName.new(name.downcase).query

    assert_equal 1, result.count
    assert_equal account.id, result.first.id
  end
end
