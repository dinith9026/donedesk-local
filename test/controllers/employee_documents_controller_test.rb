require 'test_helper'

class EmployeeDocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account_owner = users(:account_owner)
    @employee_record = employee_records(:ed)
    @document = documents(:oceanview_ed_w4)
    @employee_document = employee_documents(:oceanview_ed_w4)
    @another_document = documents(:brookside_ellen_w4)
    @another_employee_document = employee_documents(:brookside_ellen_w4)
    @valid_document_type = document_types(:oceanview_performance_review)
    @document_type = document_types(:w4)
  end

  describe '#index' do
    test 'requires authenticated user' do
      get url(user: nil), xhr: true

      assert_response :unauthorized
    end

    describe 'for account owner' do
      test 'when employee record does not belong to their account' do
        user = users(:account_owner)
        employee_record = employee_records(:ellen)

        get url(user: user, employee_record_id: employee_record.id), xhr: true

        assert_response :not_found
      end

      test 'when employee record belongs to their account' do
        user = users(:account_owner)

        get url(user: user), xhr: true

        assert_response :success
        refute_nil assigns[:employee_documents_presenter]
      end
    end

    test 'for employee' do
      get url(user: users(:employee)), xhr: true

      assert_response :success
      refute_nil assigns[:employee_documents_presenter]
    end
  end

  describe '#new' do
    it_requires_authenticated_user do
      get new_employee_record_document_url(employee_record_id: @employee_record.id)
    end

    test 'for account_owner it succeeds' do
      get new_employee_record_document_url(
            as: @account_owner, employee_record_id: @employee_record.id)

      assert_response :success
      refute_nil assigns[:document_form]
      refute_nil assigns[:employee]
    end

    test 'for employee it succeeds' do
      employee_user = users(:employee)

      get new_employee_record_document_url(
            as: employee_user, employee_record_id: employee_user.employee_record.id)

      assert_response :success
    end
  end

  describe '#create' do
    it_requires_authenticated_user do
      post employee_record_documents_url(employee_record_id: @employee_record.id)
    end

    describe 'for account_owner' do
      test 'with valid params' do
        file = { file: fixture_file_upload('test.pdf', 'application/pdf') }

        assert_difference 'Document.count', 1 do
          post employee_record_documents_url(
                  as: @account_owner, employee_record_id: @employee_record.id),
               params: { document: valid_params.merge(file) }
        end
        assert_response :redirect
        refute_nil flash[:success]
        refute_nil assigns[:document_form]
        refute_nil assigns[:employee]
      end

      test 'it fails when params are invalid' do
        assert_no_difference 'Document.count' do
          post employee_record_documents_url(
                  as: @account_owner, employee_record_id: @employee_record.id),
               params: { document: invalid_params }
        end
        assert_response :success
        assert_template :new
        refute_nil flash[:error]
        refute_nil assigns[:document_form]
        refute_nil assigns[:employee]
      end
    end

    describe 'for employee' do
      test 'with valid params' do
        employee_user = users(:employee)
        file = { file: fixture_file_upload('test.pdf', 'application/pdf') }

        assert_difference 'Document.count', 1 do
          post employee_record_documents_url(
                as: employee_user, employee_record_id: employee_user.employee_record.id),
               params: { document: valid_params.merge(file) }
        end
        assert_response :redirect
      end
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_employee_document_url(@employee_document) }

    describe 'for account_owner' do
      test 'when record belongs to their account it succeeds' do
        get edit_employee_document_url(as: @account_owner, id: @employee_document.id)

        assert_response :success
        refute_nil assigns[:document_form]
        refute_nil assigns[:employee]
      end

      test 'when record does not belong to their account it fails' do
        get edit_employee_document_url(as: @account_owner, id: @another_employee_document.id)

        assert_redirects_with_not_found_error
      end
    end

    test 'for employee it restricts access' do
      get edit_employee_document_url(as: users(:employee), id: @employee_document.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put employee_document_url(@employee_document) }

    describe 'for account_owner' do
      test 'when record belongs to their account and params are VALID it succeeds' do
        put employee_document_url(as: @account_owner, id: @employee_document.id),
          params: { document: valid_params.merge(document_type_id: @valid_document_type.id) }

        assert_response :redirect
        assert_redirected_to documents_url
        refute_nil flash[:success]
        assert_equal @valid_document_type, @employee_document.reload.document_type
      end

      test 'when record belongs to their account and params are INVALID it fails' do
        invalid_expiration_date = Date.yesterday

        put employee_document_url(as: @account_owner, id: @employee_document.id),
          params: { document: valid_params.merge(expires_on: invalid_expiration_date) }

        assert_response :success
        assert_template :edit
        refute_nil flash[:error]
        refute_nil assigns[:document_form]
        refute_equal invalid_expiration_date, @employee_document.reload.expires_on
      end

      test 'when record does not belong to their account it fails' do
        put employee_document_url(as: @account_owner, id: @another_employee_document.id)

        assert_redirects_with_not_found_error
      end
    end

    test 'for employee it restricts access' do
      put employee_document_url(as: users(:employee), id: @employee_document.id), params: { document: valid_params }

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#download' do
    it_requires_authenticated_user { get download_employee_document_url(@employee_document) }

    describe 'for account_owner' do
      test 'when record does not belong to their account' do
        get download_employee_document_path(as: @account_owner, id: @another_employee_document.id)

        assert_redirects_with_not_found_error
      end

      describe 'when record does belong to their account' do
        test 'when file type is a pdf' do
          @employee_document.document.file = fixture_file_upload('test.pdf')
          @employee_document.document.save!

          get download_employee_document_path(as: @account_owner, id: @employee_document.id)

          assert_equal response.header['Content-Type'], @employee_document.document.file_content_type
          assert_equal response.header['Content-Disposition'], "inline; filename=\"#{@employee_document.document.file_file_name}\""
        end

        test 'when file type is an image' do
          @employee_document.document.file = fixture_file_upload('selfie.jpg')
          @employee_document.document.save!

          get download_employee_document_path(as: @account_owner, id: @employee_document.id)

          assert_equal response.header['Content-Type'], @employee_document.document.file_content_type
          assert_equal response.header['Content-Disposition'], "inline; filename=\"#{@employee_document.document.file_file_name}\""
        end

        test 'when file type is not a pdf or image' do
          @employee_document.document.file = fixture_file_upload('test.docx')
          @employee_document.document.save!

          get download_employee_document_path(as: @account_owner, id: @employee_document.id)

          assert_equal response.header['Content-Type'], @employee_document.document.file_content_type
          assert_equal response.header['Content-Disposition'], "attachment; filename=\"#{@employee_document.document.file_file_name}\""
        end
      end
    end

    test 'for employee' do
      @employee_document.document.file = fixture_file_upload('test.pdf')
      @employee_document.document.save!

      get download_employee_document_path(as: users(:employee), id: @employee_document.id)

      assert_equal response.header['Content-Type'], @employee_document.document.file_content_type
      assert_equal response.header['Content-Disposition'], "inline; filename=\"#{@employee_document.document.file_file_name}\""
    end
  end

  private

  def last_document
    Document.order(:created_at).last
  end

  def valid_params
    attributes_for(:document, document_type_id: document_types(:w4).id)
  end

  def invalid_params
    { title: '' }
  end

  def url(user:, employee_record_id: nil, document_type_id: nil)
      document_type_employee_record_documents_url(
        as: user,
        employee_record_id: employee_record_id || @employee_record.id,
        document_type_id: document_type_id || @document_type.id,
        format: :js
      )
  end
end
