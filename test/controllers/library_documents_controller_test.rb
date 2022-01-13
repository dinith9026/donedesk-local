require 'test_helper'

class LibraryDocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account_owner = users(:account_owner)
    @library_document = library_documents(:oceanview_doc)
    @library_document.file = fixture_file_upload('test.pdf')
    @library_document.save!
    @another_library_document = library_documents(:brookside_doc)
  end

  describe '#index' do
    it_requires_authenticated_user { get library_documents_url }

    [:account_owner, :account_manager].each do |role|
      test "as #{role}" do
        user = users(role)

        get library_documents_url(as: user)

        assert_response :success
        assert_includes assigns.keys, 'library_documents_presenter'
      end
    end

    test 'as employee' do
      get library_documents_url(as: users(:employee))

      assert_response :success
      assert_includes assigns.keys, 'library_documents_presenter'
      assert_includes assigns['library_documents_presenter'], library_documents(:oceanview_doc)
      refute_includes assigns['library_documents_presenter'], library_documents(:oceanview_invisible_doc)
    end
  end

  describe '#new' do
    it_requires_authenticated_user { get new_library_document_url }

    test 'as account_owner' do
      get new_library_document_url(as: @account_owner)

      assert_response :success
      refute_nil assigns[:form]
      refute_nil assigns[:presenter]
    end

    test 'as employee' do
      get new_library_document_url(as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#create' do
    it_requires_authenticated_user { post library_documents_url }

    test 'as super_admin when params are valid' do
      file = { file: fixture_file_upload('test.pdf', 'application/pdf') }
      params = valid_params.merge(file).merge(is_canned: true)

      assert_difference 'LibraryDocument.count', 1 do
        post library_documents_url(as: users(:super_admin)),
          params: { library_document: params }
      end
      assert_response :redirect
      assert_redirected_to library_documents_path
      refute_nil flash[:success]
      refute_nil LibraryDocument.find_by(
                  name: params[:name],
                  file_file_name: params[:file].original_filename,
                  account_id: nil)
    end

    describe 'as account_owner' do
      test 'when params are invalid' do
        assert_no_difference 'LibraryDocument.count' do
          post library_documents_url(as: @account_owner),
            params: { library_document: invalid_params }
        end
        assert_response :success
        assert_template :new
        refute_nil flash[:error]
        refute_nil assigns[:form]
      end

      test 'when params are valid' do
        file = { file: fixture_file_upload('test.pdf', 'application/pdf') }
        params = valid_params.merge(file)

        assert_difference 'LibraryDocument.count', 1 do
          post library_documents_url(as: @account_owner),
            params: { library_document: params }
        end
        assert_response :redirect
        assert_redirected_to library_documents_path
        refute_nil flash[:success]
        refute_nil LibraryDocument.find_by(
                    name: params[:name],
                    file_file_name: params[:file].original_filename,
                    account_id: @account_owner.account_id)
      end
    end

    test 'as employee' do
      post library_documents_url(as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#show' do
    it_requires_authenticated_user { get library_document_url(@library_document) }

    describe 'as account_owner' do
      test 'when document does NOT belong to account' do
        get library_document_url(@another_library_document, as: @account_owner)

        assert_redirects_with_not_authorized_error
      end

      test 'when document belongs to account' do
        get library_document_url(@library_document, as: @account_owner)

        assert_response :success
        assert_equal response.header['Content-Type'],
          @library_document.file_content_type
        assert_equal response.header['Content-Disposition'],
          "inline; filename=\"#{@library_document.file_file_name}\""
      end
    end

    test 'as employee' do
      get library_document_url(@library_document, as: users(:employee))

      assert_response :success
      assert_equal response.header['Content-Type'],
        @library_document.file_content_type
      assert_equal response.header['Content-Disposition'],
        "inline; filename=\"#{@library_document.file_file_name}\""
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_library_document_url(@library_document) }

    test 'as account_owner' do
      get edit_library_document_url(@library_document, as: @account_owner)

      assert_response :success
      refute_nil assigns[:form]
      refute_nil assigns[:presenter]
    end

    test 'as employee' do
      get edit_library_document_url(id: @library_document, as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put library_document_url(@library_document) }

    test 'as super_admin when params are valid' do
      new_name = 'New name'
      params = @library_document.attributes.merge(name: new_name)

      put library_document_url(@library_document, as: users(:super_admin)),
        params: { library_document: params }

      assert_response :redirect
      assert_redirected_to library_documents_url
      refute_nil flash[:success]
      assert_equal new_name, @library_document.reload.name
    end

    describe 'as account_owner' do
      test 'when params are invalid' do
        new_summary = 'New summary'
        invalid_params = @library_document.attributes.merge(name: '',
                                                            summary: new_summary)

        put library_document_url(@library_document, as: @account_owner),
          params: { library_document: invalid_params }

        assert_response :success
        assert_template :edit
        refute_nil flash[:error]
        refute_nil assigns[:form]
        refute_nil assigns[:presenter]
        refute_equal new_summary, @library_document.reload.summary
      end

      test 'when params are valid' do
        new_name = 'New name'
        file = { file: fixture_file_upload('test.pdf', 'application/pdf') }
        params = valid_params.merge(file).merge(name: new_name)

        put library_document_url(@library_document, as: @account_owner),
          params: { library_document: params }

        assert_response :redirect
        assert_redirected_to library_documents_url
        refute_nil flash[:success]
        assert_equal new_name, @library_document.reload.name
      end
    end

    test 'as employee' do
      put library_document_url(@library_document, as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#download' do
    it_requires_authenticated_user { get download_library_document_url(@library_document) }

    describe 'as account_owner' do
      test 'when document does NOT belong to account' do
        get download_library_document_url(@another_library_document,
                                          as: @account_owner)

        assert_redirects_with_not_authorized_error
      end

      test 'when document belongs to account' do
        get download_library_document_url(@library_document, as: @account_owner)

        assert_response :success
        assert_equal response.header['Content-Type'],
          @library_document.file_content_type
        assert_equal response.header['Content-Disposition'],
          "attachment; filename=\"#{@library_document.file_file_name}\""
      end
    end

    test 'as employee' do
      get download_library_document_url(@library_document, as: users(:employee))

      assert_response :success
      assert_equal response.header['Content-Type'],
        @library_document.file_content_type
      assert_equal response.header['Content-Disposition'],
        "attachment; filename=\"#{@library_document.file_file_name}\""
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete library_document_url(@library_document) }

    describe 'for account_owner' do
      test 'when document does NOT belong to account' do
        delete library_document_url(@another_library_document,
                                    as: @account_owner)

        assert_redirects_with_not_authorized_error
      end

      test 'when document belongs to account' do
        assert_difference 'LibraryDocument.count', -1 do
          delete library_document_url(@library_document, as: @account_owner)
        end
        assert_response :redirect
        assert_redirected_to library_documents_url
        refute_nil flash[:success]
      end
    end

    test 'as employee' do
      delete library_document_url(@library_document, as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  private

  def valid_params
    attributes_for(:library_document)
  end

  def invalid_params
    { name: '' }
  end
end
