require 'test_helper'

class ReferralsControllerTest < ActionDispatch::IntegrationTest
  describe 'create' do
    it_requires_authenticated_user { post referrals_url }

    test 'with invalid params' do
      assert_no_difference('ActionMailer::Base.deliveries.size') do
        post referrals_url(
          as: users(:account_manager),
          params: invalid_params,
          format: :js
        ), xhr: true
      end
      assert_response :success
      assert_equal 'failure', assigns[:result]
    end

    test 'with valid params' do
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        post referrals_url(as: users(:account_manager)),
          params: valid_params, as: :js, xhr: true
      end
      assert_response :success
      assert_equal 'success', assigns[:result]
    end
  end

  private

  def valid_params
    {
      referrals: [
        { name: 'John Doe', email: 'john@example.com' },
        { name: 'Jane Doe', email: 'jane@example.com' },
        { name: '', email: '' },
      ]
    }
  end

  def invalid_params
    {
      referrals: [
        { name: '', email: '' },
      ]
    }
  end
end
