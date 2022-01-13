require 'test_helper'

class ApplicationPolicyTest < PolicyTest
  test 'as a super admin' do
    user = users(:super_admin)

    assert_permit(:index, user, Object.new)
    assert_permit(:new, user, Object.new)
    assert_permit(:create, user, Object.new)
    assert_permit(:edit, user, Object.new)
    assert_permit(:update, user, Object.new)
    assert_permit(:show, user, Object.new)
  end

  test 'as an account owner' do
    user = users(:account_owner)

    assert_permit(:index, user, Object.new)
    assert_permit(:new, user, Object.new)
    assert_permit(:create, user, Object.new)
    assert_permit(:edit, user, Object.new)
    assert_permit(:update, user, Object.new)
    assert_permit(:show, user, Object.new)
  end

  test 'as an account manager' do
    user = users(:account_manager)

    assert_permit(:index, user, Object.new)
    assert_permit(:new, user, Object.new)
    assert_permit(:create, user, Object.new)
    assert_permit(:edit, user, Object.new)
    assert_permit(:update, user, Object.new)
    assert_permit(:show, user, Object.new)
  end

  test 'as an employee' do
    user = users(:employee)

    refute_permit(:index, user, Object.new)
    refute_permit(:new, user, Object.new)
    refute_permit(:create, user, Object.new)
    refute_permit(:edit, user, Object.new)
    refute_permit(:update, user, Object.new)
    refute_permit(:show, user, Object.new)
  end
end