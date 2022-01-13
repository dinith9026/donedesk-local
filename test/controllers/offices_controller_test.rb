require 'test_helper'

class OfficesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:oceanview_dental)
    @document_group = create_office_document_group_for(@account)
    @account_owner = @account.owner
    @office = offices(:oceanview_tx)
    @another_office = offices(:brookside)
    @super_admin = users(:super_admin)
  end

  describe '#index' do
    it_requires_authenticated_user { get offices_url }

    test "for account_owner it lists only the records for their account" do
      get offices_url(as: @account_owner)

      assert_response :success
      refute_includes assigns[:offices_presenter], @another_office
    end

    test 'for employee it restricts access' do
      get offices_url(as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#new' do
    it_requires_authenticated_user { get new_office_url }

    test 'for account_owner it succeeds' do
      get new_office_url(as: @account_owner)

      assert_response :success
      refute_nil assigns[:form]
    end

    test 'for employee it restricts access' do
      get new_office_url(as: users(:employee))

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#create' do
    it_requires_authenticated_user { post offices_url }

    test 'for super_admin when params are VALID' do
      assert_difference 'Office.count', 1 do
        post offices_url(as: @super_admin), params: { office: valid_params }
      end
      assert_response :redirect
      refute_nil flash[:success]
    end

    describe 'for account_owner' do
      test 'when params are VALID' do
        assert_difference 'Office.count', 1 do
          post offices_url(as: @account_owner), params: { office: valid_params }
        end
        assert_response :redirect
        refute_nil flash[:success]
      end

      test 'when params are INVALID' do
        assert_no_difference 'Office.count' do
          post offices_url(as: @account_owner), params: { office: invalid_params }
        end
        assert_response :success
        assert_template :new
        refute_nil assigns[:form]
      end
    end

    test 'for employee it restricts access' do
      post offices_url(as: users(:employee), params: { office: valid_params })

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#show' do
    it_requires_authenticated_user { get office_url(@office) }

    describe 'for account owner' do
      test 'when record belongs to their account it fails' do
        get office_url(as: @account_owner, id: @another_office.id)

        assert_redirects_with_not_found_error
      end

      test 'when record belongs to their account it succeeds' do
        get office_url(as: @account_owner, id: @office.id)

        assert_response :success
        assert_equal @office.id, assigns[:office_presenter].id
      end
    end

    test 'for employee it restricts access' do
      get office_url(as: users(:employee), id: @office.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_office_url(@office) }

    describe 'for account_owner' do
      test 'when record belongs to their account it succeeds' do
        get edit_office_url(as: @account_owner, id: @office.id)

        assert_response :success
        refute_nil assigns[:form]
      end

      test 'when record does not belong to their account it fails' do
        get edit_office_url(as: @account_owner, id: @another_office.id)

        assert_redirects_with_not_found_error
      end
    end

    test 'for employee it restricts access' do
      get edit_office_url(as: users(:employee), id: @office.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put office_url(@office) }

    describe 'for account_owner' do
      test 'when record belongs to their account and params are VALID it succeeds' do
        new_name = 'New name'

        put office_url(as: @account_owner, id: @office.id),
          params: { office: valid_params.merge(name: new_name) }

        assert_response :redirect
        refute_nil flash[:success]
        assert_equal new_name, Office.find(@office.id).name
      end

      test 'when record belongs to their account and params are INVALID it fails' do
        new_city = 'New City'

        put office_url(as: @account_owner, id: @office.id),
          params: { office: invalid_params.merge(city: new_city) }

        assert_response :success
        assert_template :edit
        refute_nil assigns[:form]
        refute_equal new_city, Office.find(@office.id).city
      end

      test 'when record does not belong to their account it fails' do
        put office_url(as: @account_owner, id: @another_office.id)

        assert_redirects_with_not_found_error
      end
    end

    test 'for employee it restricts access' do
      put office_url(as: users(:employee), id: @office.id)

      assert_redirects_with_not_authorized_error
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete office_url(@office) }

    test 'for super admin' do
      # Need an office without employee records
      office = create(:office, account: @account, document_group: @document_group)

      put current_account_url(as: @super_admin, current_account_name: @account.name)

      assert_difference 'Office.count', -1 do
        delete office_url(as: @super_admin, id: office.id)
      end
      assert_redirected_to offices_url
    end

    describe 'for account owner' do
      test 'when office does NOT belong to current account' do
        assert_no_difference 'Office.count' do
          delete office_url(as: @account_owner, id: @another_office.id)
        end
        assert_redirects_with_not_found_error
      end

      describe 'when office belongs to current account' do
        test 'and has employee records associated with it' do
          assert_no_difference 'Office.count' do
            delete office_url(as: @account_owner, id: @office.id)
          end
          assert_redirects_with_not_authorized_error
        end

        test 'and has NO employee records associated with it' do
          office = create(:office, account: @account_owner.account, document_group: @document_group)

          assert_difference 'Office.count', -1 do
            delete office_url(as: @account_owner, id: office.id)
          end
          assert_response :redirect
          assert_redirected_to offices_url
        end
      end
    end
  end

  private

  def valid_params
    attributes_for(:office)
      .merge(account_id: @account.id)
      .merge(document_group_id: @document_group.id)
  end

  def invalid_params
    params = valid_params.clone
    params[:name] = ''
    params
  end
end
