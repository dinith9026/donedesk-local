require 'test_helper'

class OfficeDocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @office = offices(:oceanview_tx)
    @another_office = offices(:brookside)
    @document_type = document_types(:office_maintenance_checklist)
    @office_document = office_documents(:oceanview_tx_maintenance_checklist)
    @another_office_document = office_documents(:brookside_maintenance_checklist)
  end

  describe '#index' do
    test 'requires authenticated user' do
      get build_index_url(user: nil), xhr: true

      assert_response :unauthorized
    end

    test 'for super_admin' do
      user = users(:super_admin)
      set_current_account

      get build_index_url(user: user), xhr: true

      assert_response :success
      assert_includes assigns.keys, 'office_documents_presenter'
    end

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when office does not belong to their account' do
          user = users(role)

          get build_index_url(user: user, office_id: @another_office.id), xhr: true

          assert_response :not_found
        end

        test 'when office belongs to their account' do
          user = users(role)

          get build_index_url(user: user), xhr: true

          assert_response :success
          assert_includes assigns.keys, 'office_documents_presenter'
        end
      end
    end

    test 'for employee' do
      get build_index_url(user: users(:employee)), xhr: true

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#new' do
    it_requires_authenticated_user { get new_office_document_url(office_id: @office.id) }

    test 'for super_admin' do
      set_current_account

      get new_office_document_url(as: users(:super_admin), office_id: @office.id)

      assert_response :success
      assert_includes assigns.keys, 'document_form'
    end

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when office does not belong to their account' do
          user = users(role)

          get new_office_document_url(as: user, office_id: @another_office.id)

          assert_redirects_with_not_found_error
        end

        test 'when office belongs to their account' do
          user = users(role)

          get new_office_document_url(as: user, office_id: @office.id)

          assert_response :success
          assert_includes assigns.keys, 'document_form'
        end
      end
    end

    test 'for employee' do
      get new_office_document_url(as: users(:employee), office_id: @office.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#create' do
    it_requires_authenticated_user { post office_documents_url(office_id: @office.id) }

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'with invalid params' do
          user = users(role)

          assert_no_difference 'OfficeDocument.count', 'Document.count' do
            post office_documents_url(as: user, office_id: @office.id),
                 params: { document: { document_type_id: '' } }
          end
          assert_response :success
          assert_template :new
          refute_nil flash[:error]
          assert_includes assigns.keys, 'document_form'
          assert_includes assigns.keys, 'office'
        end

        test 'with valid params' do
          user = users(role)

          file = { file: fixture_file_upload('test.pdf', 'application/pdf') }

          assert_differences([['OfficeDocument.count', 1], ['Document.count', 1]]) do
            post office_documents_url(as: user, office_id: @office.id),
                 params: { document: valid_params.merge(file) }
          end
          assert_redirects_with_flash_success(@office)
        end
      end
    end

    test 'for employee' do
      file = { file: fixture_file_upload('test.pdf', 'application/pdf') }

      post office_documents_url(as: users(:employee), office_id: @office.id),
           params: { document: valid_params.merge(file) }

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_office_document_url(id: @office_document.id) }

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when document does not belong to their account' do
          user = users(role)

          get edit_office_document_url(as: user, id: @another_office_document.id)

          assert_redirects_with_not_found_error
        end

        test 'when document belongs to their account' do
          user = users(role)

          get edit_office_document_url(as: user, id: @office_document.id)

          assert_response :success
          assert_includes assigns.keys, 'document_form'
          assert_includes assigns.keys, 'office_document'
        end
      end
    end

    test 'for employee' do
      get edit_office_document_url(as: users(:employee), id: @office_document.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put office_document_url(id: @office_document.id) }

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when document does not belong to their account' do
          user = users(role)

          put office_document_url(as: user, id: @another_office_document.id),
            params: { document: {} }

          assert_redirects_with_not_found_error
        end

        test 'when document belongs to their account and params are INVALID' do
          invalid_expiration_date = Date.yesterday
          user = users(role)

          put office_document_url(as: user, id: @office_document.id),
            params: { document: { expires_on: invalid_expiration_date } }

          assert_response :success
          refute_nil flash[:error]
          assert_includes assigns.keys, 'document_form'
          assert_includes assigns.keys, 'office_document'
          refute_equal invalid_expiration_date, @office_document.reload.expires_on
        end

        test 'when document belongs to their account and params are VALID' do
          valid_params = { document_type_id: @office_document.document_type_id, summary: "New summary" }
          user = users(role)

          put office_document_url(as: user, id: @office_document.id),
            params: { document: valid_params }

          assert_redirects_with_flash_success(root_url)
          assert_equal valid_params[:summary], @office_document.reload.summary
        end
      end
    end

    test 'for employee' do
      put office_document_url(as: users(:employee), id: @office_document.id),
        params: { document: {} }

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#download' do
    it_requires_authenticated_user { get download_office_document_url(@office_document) }

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when document does not belong to their account' do
          user = users(role)

          get download_office_document_url(as: user, id: @another_office_document.id)

          assert_redirects_with_not_found_error
        end

        test 'when document belongs to their account' do
          @office_document.document.file = fixture_file_upload('test.pdf')
          @office_document.document.save!
          user = users(role)

          get download_office_document_url(as: user, id: @office_document.id)

          assert_equal response.header['Content-Type'], @office_document.document.file_content_type
          assert_equal response.header['Content-Disposition'], "inline; filename=\"#{@office_document.document.file_file_name}\""
        end
      end
    end

    test 'for employee' do
      get download_office_document_url(as: users(:employee), id: @office_document.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete office_document_url(id: @office_document.id) }

    test 'for super_admin' do
      set_current_account

      delete office_document_url(as: users(:super_admin), id: @office_document.id)

      assert_redirects_with_flash_success(root_url)
    end

    [:account_owner, :account_manager].each do |role|
      describe "for #{role}" do
        test 'when document does not belong to their account' do
          user = users(role)

          delete office_document_url(as: user, id: @another_office_document.id)

          assert_redirects_with_not_found_error
        end

        test 'when document belongs to their account' do
          user = users(role)

          delete office_document_url(as: user, id: @office_document.id)

          assert_redirects_with_flash_success(root_url)
        end
      end
    end

    test 'for employee' do
      delete office_document_url(as: users(:employee), id: @office_document.id)

      assert_redirects_with_not_authorized_error
    end
  end

  private

  def build_index_url(user:, office_id: nil, document_type_id: nil)
      document_type_office_documents_url(
        as: user,
        office_id: office_id || @office.id,
        document_type_id: document_type_id || @document_type.id,
        format: :js
      )
  end

  def set_current_account
    put current_account_url(as: users(:super_admin), current_account_name: accounts(:oceanview_dental).name)
  end

  def valid_params
    attributes_for(:document, document_type_id: document_types(:office_maintenance_checklist).id)
  end
end
