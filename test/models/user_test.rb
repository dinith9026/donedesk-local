require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should validate_presence_of(:first_name)
  should validate_presence_of(:last_name)
  should validate_presence_of(:email)
  should_not allow_value('invalid').for(:email)
  should validate_length_of(:password)
    .is_at_least(DoneDesk::MIN_PASSWORD_LENGTH)
  should_not allow_values('NOLOWER1', 'noupper1', 'NoDigits').for(:password)
  should define_enum_for(:role)
    .with_values({ super_admin: 1, account_owner: 3, account_manager: 4, employee: 5  })
  should allow_value({}).for(:chat_terms)
  should allow_value(nil).for(:chat_terms)
  should_not allow_value({accepted_at: nil, ip_address: nil}).for(:chat_terms)
  should_not allow_value({accepted_at: Time.now.utc, ip_address: nil}).for(:chat_terms)
  should_not allow_value({accepted_at: nil, ip_address: '111.222.333.444'}).for(:chat_terms)
  should allow_value({accepted_at: Time.now.utc, ip_address: '111.222.333.444'}).for(:chat_terms)

  describe '#has_accepted_chat_terms?' do
    test 'when NOT accepted' do
      user = build(:user, chat_terms: nil)

      assert_equal false, user.has_accepted_chat_terms?
    end

    test 'when accepted' do
      user = build(:user, chat_terms: build(:chat_terms))

      assert_equal true, user.has_accepted_chat_terms?
    end
  end

  describe '#gravatar_url' do
    test 'when size is NOT provided' do
      user = users(:employee)
      gravatar = Digest::MD5::hexdigest(user.email).downcase

      assert_equal "https://www.gravatar.com/avatar/#{gravatar}.png?s=100&default=mp", user.gravatar_url
    end

    test 'when size is provided' do
      user = users(:employee)
      gravatar = Digest::MD5::hexdigest(user.email).downcase

      assert_equal "https://www.gravatar.com/avatar/#{gravatar}.png?s=200&default=mp", user.gravatar_url(200)
    end
  end

  describe '#time_zone' do
    test 'when user is NOT associated with an office' do
      assert_equal 'UTC', users(:account_owner).time_zone
    end

    test 'when user is associated with an office' do
      assert_equal 'Central Time (US & Canada)', users(:employee).time_zone
    end
  end

  describe '#tracks_time?' do
    test 'when employee record does NOT exist' do
      assert_equal false, users(:account_owner).tracks_time?
    end

    describe 'when employee record exists' do
      test 'and time tracking is disabled for account' do
        account = Account.new(time_tracking: false)
        employee_record = EmployeeRecord.new
        user = User.new(account: account, employee_record: employee_record)
        assert_equal false, user.tracks_time?
      end

      test 'and time tracking is enabled for account but disabled for office' do
        account = Account.new(time_tracking: true)
        office = Office.new(tracks_time: false)
        employee_record = EmployeeRecord.new(office: office)
        user = User.new(account: account, employee_record: employee_record)
        assert_equal false, user.tracks_time?
      end

      test 'and time tracking is enabled for both account and office' do
        account = Account.new(time_tracking: true)
        office = Office.new(tracks_time: true)
        employee_record = EmployeeRecord.new(office: office)
        user = User.new(account: account, employee_record: employee_record)
        assert_equal true, user.tracks_time?
      end
    end
  end

  test '#full_name' do
    subject = User.new(first_name: 'Ron', last_name: 'Swanson')

    result = subject.full_name

    assert_equal 'Ron Swanson', result
  end

  describe '#change_role_to!' do
    test 'from employee to account_manager' do
      user = users(:employee)

      user.change_role_to!('account_manager')

      assert_equal 'account_manager', user.reload.role
    end

    test 'from account_manager to employee' do
      user = users(:account_manager)
      create(:offices_user, office: user.employee_record.office, user: user)

      user.change_role_to!('employee')

      assert_equal 'employee', user.reload.role
      assert_equal 0, user.reload.assigned_offices.count
    end
  end

  test '#user_hash_for_intercom' do
    user = users(:employee)
    expected_hash = OpenSSL::HMAC.hexdigest(
      'sha256',
      DoneDesk::Secrets.intercom_api_secret,
      user.id
    )

    result = user.user_hash_for_intercom

    assert_equal expected_hash, result
  end

  describe '#two_factor_required?' do
    test 'when not set for user and user has no account (e.g. super admin)' do
      user = User.new(two_factor_enabled: nil, account: nil)

      result = user.two_factor_required?

      assert_equal true, result
    end

    test 'when enabled for user and user has no account (e.g. super admin)' do
      user = User.new(two_factor_enabled: true, account: nil)

      result = user.two_factor_required?

      assert_equal true, result
    end

    test 'when disabled for user and user has no account (e.g. super admin)' do
      user = User.new(two_factor_enabled: false, account: nil)

      result = user.two_factor_required?

      assert_equal false, result
    end

    test 'when enabled for user' do
      user = User.new(two_factor_enabled: true)

      result = user.two_factor_required?

      assert_equal true, result
    end

    test 'when disabled for user' do
      user = User.new(two_factor_enabled: false)

      result = user.two_factor_required?

      assert_equal false, result
    end

    test 'when enabled for account and not set for user' do
      account = Account.new(two_factor_enabled: true)
      user = User.new(two_factor_enabled: nil, account: account)

      result = user.two_factor_required?

      assert_equal true, result
    end

    test 'when disabled for account and not set for user' do
      account = Account.new(two_factor_enabled: false)
      user = User.new(two_factor_enabled: nil, account: account)

      result = user.two_factor_required?

      assert_equal false, result
    end
  end

  describe '#two_factor_setup?' do
    test 'when not setup' do
      user = User.new(two_factor_setup_at: nil)

      result = user.two_factor_setup?

      assert_equal false, result
    end

    test 'when setup' do
      user = User.new(two_factor_setup_at: DateTime.new)

      result = user.two_factor_setup?

      assert_equal true, result
    end
  end
end
