require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  describe 'due_in_or_past_due_x_days' do
    test 'when arg is nil' do
      assert_nil due_in_or_past_due_x_days(nil)
    end

    test 'when arg is empty string' do
      assert_nil due_in_or_past_due_x_days('')
    end

    test 'when arg is a string' do
      assert_equal '(due in 1 day)', due_in_or_past_due_x_days('1')
    end

    test 'when days_until_due is less than 0' do
      assert_equal "<span style=\"color: red\">(past due 1 day)</span>", due_in_or_past_due_x_days(-1)
    end

    test 'when days_until_due is 0' do
      assert_equal "<span style=\"color: red\">(due today)</span>", due_in_or_past_due_x_days(0)
    end

    test 'when days_until_due is greater than 0' do
      assert_equal "(due in 1 day)", due_in_or_past_due_x_days(1)
    end
  end

  describe 'due_date' do
    test 'when arg is nil' do
      assert_nil due_date(nil)
    end

    test 'when arg is empty string' do
      assert_nil due_date('')
    end

    test 'when arg is a datetime' do
      datetime = 1.day.from_now
      expected = I18n.localize(datetime.to_date, format: :default)

      assert_equal expected, due_date(datetime)
    end

    test 'when date is in the future' do
      date = 1.day.from_now.to_date
      expected = I18n.localize(date, format: :default)

      assert_equal expected, due_date(date)
    end

    test 'when date is today' do
      date = Date.current
      expected = I18n.localize(date, format: :default)

      assert_equal expected, due_date(date)
    end

    test 'when date is in the past' do
      date = 1.day.ago.to_date
      expected = I18n.localize(date, format: :default)

      assert_equal "<span class=\"text-danger\">#{expected}</span>", due_date(date)
    end
  end

  describe 'valid_date?' do
    test 'when month is invalid' do
      assert_equal false, valid_date?('13/01/2020')
    end

    test 'when day is invalid' do
      assert_equal false, valid_date?('12/32/2020')
    end

    test 'when year is invalid' do
      assert_equal false, valid_date?('12/01/0')
    end

    test 'when month, day and year are all valid' do
      assert_equal true, valid_date?('12/01/2020')
    end
  end

  describe 'user_avatar_url' do
    describe 'when user is present' do
      test 'and avatar exists' do
        user = build(:user, :with_avatar)

        result = user_avatar_url(user)

        assert_includes result, 's3.us-west-2.amazonaws.com'
      end

      test 'and avatar does not exist' do
        user = build(:user, email: 'user@example.com')

        result = user_avatar_url(user)

        assert_match /https:\/\/www.gravatar.com\/avatar\/[a-zA-Z0-9]{32}.png\?s=300&default=mp/, result
      end
    end

    test 'when user is NOT present' do
      user = nil

      result = user_avatar_url(user)

      assert_equal result, 'https://www.gravatar.com/avatar/?s=300&default=mp'
    end
  end

  describe 'when_user_tracks_time' do
    test 'when true' do
      user = User.new
      user.stubs(:tracks_time?).returns(true)
      block_called = false

      when_user_tracks_time(user) { block_called = true }

      assert_equal true, block_called
    end

    test 'when false' do
      user = User.new
      user.stubs(:tracks_time?).returns(false)
      block_called = false

      when_user_tracks_time(user) { block_called = true }

      assert_equal false, block_called
    end
  end

  describe 'when_user_can' do
    test 'when they cannot' do
      policy_stub = Struct.new(:update?).new(false)
      block_called = false

      when_user_can(:update, policy_stub) do
        block_called = true
      end

      assert_equal false, block_called
    end

    test 'when they can' do
      policy_stub = Struct.new(:update?).new(true)
      block_called = false

      when_user_can(:update, policy_stub) do
        block_called = true
      end

      assert_equal true, block_called
    end
  end

  test 'account_names' do
    oceanview = accounts(:oceanview_dental)
    brookside = accounts(:brookside_dental)

    result = account_names([oceanview, brookside])

    assert_equal [oceanview.name, brookside.name], result
  end

  test 'bootstrap_class_for' do
    assert_equal 'alert-success', bootstrap_class_for('success')
    assert_equal 'alert-danger', bootstrap_class_for('error')
    assert_equal 'alert-warning', bootstrap_class_for('alert')
    assert_equal 'alert-info', bootstrap_class_for('notice')
    assert_equal 'alert-anything', bootstrap_class_for('anything')
  end

  test 'nav_link' do
    icon_type = 'test'
    link_text = 'Test'
    link_path = '/dashboard'
    menu_type = 'menu-item'
    request_path = link_path
    expected = <<-HTML.strip
      <li class="nav-item active"><a href="#{link_path}"><i class="icon icon-#{icon_type}"></i><span class="#{menu_type}">#{link_text}</span></a></li>
HTML

    assert_equal expected, nav_link(request_path, link_text, link_path, menu_type, icon_type)
  end
end
