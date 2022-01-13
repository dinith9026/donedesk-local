require 'test_helper'

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  describe '#index' do
    it_requires_authenticated_user { get documents_url }

    [:account_owner, :account_manager].each do |role|
      test "for #{role}" do
        get documents_url(as: users(role))

        assert_response :success
        refute_nil assigns[:documents_presenter]
        refute_includes assigns[:documents_presenter], employee_documents(:brookside_ellen_w4)
      end
    end

    test 'for employee it restricts access' do
      get documents_url(as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end
end
