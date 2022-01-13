require 'test_helper'

class DocumentTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @current_user = users(:account_manager)
    @account = @current_user.account
    @account_owner = @account.owner
    @another_account = accounts(:brookside_dental)
    @unauthorized_user = users(:another_account_owner)
    @employee = employee_records(:ed)
    @document_type = document_types(:oceanview_performance_review)
    @another_document_type = document_types(:brookside_performance_review)
  end

  describe '#index' do
    it_requires_authenticated_user { get document_types_url }

    test "for account_owner it lists only the records for their account" do
      get document_types_url(as: @account_owner)

      assert_response :success
      refute_includes assigns[:document_types_presenter],
        @another_account.document_types.first
    end

    test 'for employee it restricts access' do
      get document_types_url(as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#new' do
    it_requires_authenticated_user { get new_document_type_url }

    test 'for account_owner it succeeds' do
      get new_document_type_url(as: @account_owner, account_id: @account.id)

      assert_response :success
      refute_nil assigns[:form]
    end

    test 'for employee it restricts access' do
      get new_document_type_url(as: users(:employee))
      assert_redirects_with_not_authorized_error
    end
  end

  describe '#create' do
    it_requires_authenticated_user { post document_types_url }

    describe 'format.html' do
      test 'with valid params' do
        assert_difference 'DocumentType.count', 1 do
          post document_types_url(as: @current_user),
                params: { document_type: valid_params }
        end
        assert_response :redirect
        refute_nil flash[:success]
        refute_nil assigns[:form]
      end

      test 'it fails when params are invalid' do
        assert_no_difference 'DocumentType.count' do
          post document_types_url(as: @account_owner, params: { document_type: invalid_params })
        end
        assert_response :success
        refute_nil assigns[:form]
      end

      test 'for employee it restricts access' do
        post document_types_url(as: users(:employee), params: { document_type: valid_params })
        assert_redirects_with_not_authorized_error
      end
    end

    describe 'format.js' do
      test 'with invalid params' do
        existing_type = document_types(:oceanview_performance_review)
        invalid_params = { document_type: { name: existing_type.name } }

        assert_no_difference('DocumentType.count') do
          post document_types_url(
            as: @current_user,
            params: invalid_params,
            format: :js
          ), xhr: true
        end
        assert_response :success
        assert_template :create
      end

      test 'with valid params' do
        name = SecureRandom.hex
        valid_params = { document_type: { name: name, applies_to: 'employees' } }

        assert_difference('DocumentType.count', 1) do
          post document_types_url(
            as: @current_user,
            params: valid_params,
            format: :js
          ), xhr: true
        end

        last_document_type = DocumentType.find_by(name: name)

        assert_response :success
        assert_template :create
        assert_equal name, last_document_type.name
      end
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_document_type_url(@document_type) }

    describe 'for account_owner' do
      test 'when record belongs to their account it succeeds' do
        get edit_document_type_url(as: @account_owner, id: @document_type.id)

        assert_response :success
        refute_nil assigns[:form]
      end

      test 'when record does not belong to their account it fails' do
        get edit_document_type_url(as: @unauthorized_user, id: @document_type.id)

        assert_redirects_with_not_found_error
      end
    end

    test 'for employee it restricts access' do
      get edit_document_type_url(as: users(:employee), id: @document_type.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put document_type_url(@document_type) }

    describe 'for account_owner' do
      test 'when record belongs to their account and params are VALID it succeeds' do
        put document_type_url(as: @account_owner, id: @document_type.id),
          params: { document_type: valid_params.merge(name: 'I-9') }

        assert_response :redirect
        refute_nil flash[:success]
        assert_equal 'I-9', DocumentType.find(@document_type.id).name
      end

      test 'when record belongs to their account and params are INVALID it fails' do
        new_name = ''

        put document_type_url(as: @account_owner, id: @document_type.id),
          params: { document_type: invalid_params.merge(name: new_name) }

        assert_response :success
        assert_template :edit
        refute_nil assigns[:form]
        refute_equal new_name, DocumentType.find(@document_type.id).name
      end

      test 'when record does not belong to their account it fails' do
        put document_type_url(as: @unauthorized_user, id: @document_type.id)

        assert_redirects_with_not_found_error
      end
    end

    test 'for employee it restricts access' do
      put document_type_url(as: users(:employee), id: @document_type.id), params: { document_type: valid_params }

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete document_type_url(@document_type) }

    describe 'for account owner' do
      test 'when document type does NOT belong to current account' do
        assert_no_difference 'DocumentType.count' do
          delete document_type_url(as: @account_owner, id: @another_document_type.id)
        end
        assert_redirects_with_not_found_error
      end

      describe 'when document type belongs to current account' do
        test 'and has documents associated with it' do
          assert_no_difference 'DocumentType.count' do
            delete document_type_url(as: @account_owner, id: @document_type.id)
          end
          assert_redirects_with_not_authorized_error
        end

        test 'and has NO documents associated with it' do
          document_type = create(:document_type, account: @account_owner.account)

          assert_difference 'DocumentType.count', -1 do
            delete document_type_url(as: @account_owner, id: document_type.id)
          end
          assert_response :redirect
          assert_redirected_to document_types_url
        end
      end
    end
  end

  private

  def valid_params
    attributes_for(:document_type, account_id: @account.id, applies_to: 'employees')
  end

  def invalid_params
    { name: '' }
  end
end
