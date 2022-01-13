require 'test_helper'

class ChatControllerTest < ActionDispatch::IntegrationTest
  describe '#show' do
    it_requires_authenticated_user { get chat_url }

    test 'when chat terms have NOT been accepted' do
      user = users(:account_owner)

      get chat_url(as: user)

      assert_redirects_with_not_authorized_error
    end

    describe 'when chat terms have been accepted' do
      setup do
        [:account_owner, :account_manager, :employee].each do |role|
          user = users(role)
          user.update!(chat_terms: build(:chat_terms))
        end
      end

      test 'when user_id is present and user does NOT belong to current account' do
        user = users(:account_owner)
        other_user = users(:another_employee)

        get chat_url(as: user), params: { user_id: other_user.id }

        assert_redirects_with_not_found_error
      end

      test 'when user_id is present and user belongs to current account' do
        user = users(:account_owner)
        other_user = users(:employee)

        get chat_url(as: user), params: { user_id: other_user.id }

        assert_redirects_with_not_authorized_error
      end

      [:account_owner, :account_manager, :employee].each do |role|
        test "for #{role}" do
          user = users(role)

          get chat_url(as: user)

          assert_redirects_with_not_authorized_error
        end
      end
    end
  end
end
