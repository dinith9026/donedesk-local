require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'with 2FA enabled for account and not set or setup for user'do
    user = users(:account_manager)
    enable_two_factor!(user.account)

    count_before = user.sign_in_count
    params = { email: user.email, password: default_password }

    post session_url(params: { session: params })

    user.reload

    assert_redirected_to root_url
    assert_equal count_before + 1, user.sign_in_count
    refute_nil user.last_sign_in_at
    refute_nil user.last_sign_in_ip
  end

  test 'with 2FA enabled but not setup 'do
    user = users(:account_manager)
    enable_two_factor!(user)

    count_before = user.sign_in_count
    params = { email: user.email, password: default_password }

    post session_url(params: { session: params })

    user.reload

    assert_redirected_to root_url
    assert_equal count_before + 1, user.sign_in_count
    refute_nil user.last_sign_in_at
    refute_nil user.last_sign_in_ip
  end

  describe 'with 2FA enabled and setup' do
    setup do
      @user = users(:account_manager)
      enable_two_factor!(@user)
      @user.two_factor_setup!
      @user.generate_two_factor_secret_if_missing!
    end

    test 'when email does not exist' do
      count_before = @user.sign_in_count
      params = { email: 'non-existent', password: default_password }

      post session_url(params: { session: params })

      @user.reload

      assert_response :unauthorized
      assert_template :new
      refute_nil flash[:alert]
      assert_equal flash[:alert], 'Bad email or password.'
      assert_equal count_before, @user.sign_in_count
      assert_nil @user.last_sign_in_at
      assert_nil @user.last_sign_in_ip
    end

    test 'when email exists but password is wrong' do
      count_before = @user.sign_in_count
      params = { email: @user.email, password: 'wrong' }

      post session_url(params: { session: params })

      @user.reload

      assert_response :unauthorized
      assert_template :new
      refute_nil flash[:alert]
      assert_equal flash[:alert], 'Bad email or password.'
      assert_equal count_before, @user.sign_in_count
      assert_nil @user.last_sign_in_at
      assert_nil @user.last_sign_in_ip
    end

    test 'when email exists and password is correct but OTP code is invalid' do
      count_before = @user.sign_in_count
      params = { email: @user.email, password: default_password }

      post session_url(params: { session: params })

      assert_template 'sessions/two_factor'

      post session_url(params: { session: { otp_attempt: 'wrong' }})

      @user.reload

      assert_response :unauthorized
      assert_template 'sessions/two_factor'
      refute_nil flash[:alert]
      assert_equal flash[:alert], 'Invalid code. Try again.'
      assert_equal count_before, @user.sign_in_count
      assert_nil @user.last_sign_in_at
      assert_nil @user.last_sign_in_ip
    end

    test 'when email exists and password is correct and OTP code is valid' do
      count_before = @user.sign_in_count
      params = { email: @user.email, password: default_password }

      post session_url(params: { session: params })

      assert_template 'sessions/two_factor'

      post session_url(params: { session: { otp_attempt: @user.otp_code }})

      @user.reload

      assert_redirected_to root_url
      assert_equal count_before + 1, @user.sign_in_count
      refute_nil @user.last_sign_in_at
      refute_nil @user.last_sign_in_ip
    end
  end
end
