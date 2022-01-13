require 'test_helper'

class DocumentGroupPresetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:oceanview_dental)
    @preset = create_document_group_preset
  end

  describe '#index' do
    it_requires_authenticated_user { get document_group_presets_url }

    test 'as super_admin' do
      get document_group_presets_url(as: users(:super_admin))

      assert_response :success
      assert_template :index
      assert_includes assigns.keys, 'document_group_presets'
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as #{role}" do
        get document_group_presets_url(as: users(role))

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#new' do
    it_requires_authenticated_user { get new_document_group_preset_url }

    test 'as super_admin' do
      get new_document_group_preset_url(as: users(:super_admin))

      assert_response :success
      assert_template :new
      assert_includes assigns.keys, 'document_types'
      assert_includes assigns.keys, 'form'
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as #{role}" do
        get new_document_group_preset_url(as: users(role))

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#create' do
    it_requires_authenticated_user { post document_group_presets_url }

    describe 'as super_admin' do
      test 'when params are invalid' do
        assert_no_difference 'DocumentGroupPreset.count' do
          post document_group_presets_url(as: users(:super_admin)),
            params: { document_group_preset: { name: '', applies_to: 'employees' } }
        end
        assert_response :success
        assert_template :new
        assert_includes assigns.keys, 'group'
        assert_includes assigns.keys, 'form'
        assert_includes assigns.keys, 'document_types'
      end

      test 'when params are valid' do
        name = SecureRandom.hex
        w4 = document_types(:w4)
        agreements = document_types(:agreements)
        valid_params = {
          document_group_preset: attributes_for(:document_group, name: name),
          document_types_groupings: [
            { id: w4.id, required: true },
            { id: agreements.id }
          ]
        }

        assert_difference 'DocumentGroupPreset.count', 1 do
          post document_group_presets_url(as: users(:super_admin)),
            params: valid_params
        end

        new_preset = DocumentGroupPreset.find_by(name: name)

        assert_redirects_with_flash_success(document_group_preset_path(new_preset))
        assert_equal name, new_preset.name
        assert_equal true, type_for(new_preset, w4)['required']
        assert_equal false, type_for(new_preset, agreements)['required']
      end
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as #{role}" do
        post document_group_presets_url(as: users(role)),
            params: { document_group_preset: { name: '' } }

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#show' do
    it_requires_authenticated_user { get document_group_preset_url(@preset) }

    test 'as super_admin' do
      get document_group_preset_url(@preset, as: users(:super_admin))

      assert_response :success
      assert_template :show
      assert_includes assigns.keys, 'document_group_preset'
      assert_includes assigns.keys, 'document_type_names'
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as #{role}" do
        get document_group_preset_url(@preset, as: users(role))

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#edit' do
    it_requires_authenticated_user { get edit_document_group_preset_url(@preset) }

    test 'as super_admin' do
      get edit_document_group_preset_url(@preset, as: users(:super_admin))

      assert_response :success
      assert_template :edit
      assert_includes assigns.keys, 'document_group_preset'
      assert_includes assigns.keys, 'document_types'
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as #{role}" do
        get edit_document_group_preset_url(@preset, as: users(role))

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#update' do
    it_requires_authenticated_user { put document_group_preset_url(@preset) }

    describe 'as super_admin' do
      test 'with invalid params' do
        old_name = @preset.name
        new_name = SecureRandom.hex
        create_document_group_preset(new_name)
        invalid_params = { document_group_preset: { name: new_name } }

        put document_group_preset_url(@preset, as: users(:super_admin)), params: invalid_params

        @preset.reload

        assert_response :success
        assert_template :edit
        assert_includes assigns.keys, 'document_group_preset'
        assert_includes assigns.keys, 'document_types'
        assert_includes assigns.keys, 'form'
        assert_equal old_name, @preset.name
      end

      test 'with valid params' do
        new_name = SecureRandom.hex
        w4 = document_types(:w4)
        cpr_certification = document_types(:cpr_certification)
        valid_params = {
          document_group_preset: { name: new_name },
          # Make required fields the opposite of fixtures and eliminate performance review
          document_types_groupings: [
            { id: w4.id },
            { id: cpr_certification.id, required: true }
          ]
        }

        put document_group_preset_url(@preset, as: users(:super_admin)), params: valid_params

        @preset.reload

        assert_redirects_with_flash_success(document_group_preset_path(@preset))
        assert_equal new_name, @preset.name
        assert_equal false, type_for(@preset, w4)['required']
        assert_equal true, type_for(@preset, cpr_certification)['required']
      end
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as #{role}" do
        put document_group_preset_url(@preset, as: users(role))

        assert_redirects_with_not_authorized_error
      end
    end
  end

  describe '#copy' do
    it_requires_authenticated_user { post copy_document_group_preset_url(@preset) }

    [:account_owner, :account_manager].each do |role|
      describe "as #{role}" do
        test 'when group with same name already exists' do
          create_office_document_group_for(@account, @preset.name)

          assert_no_difference(['DocumentGroup.count', 'DocumentTypesGrouping.count']) do
            post copy_document_group_preset_url(@preset, as: users(role))
          end
          assert_redirects_with_flash_error(document_groups_path)
        end

        test 'when no group exists with preset name' do
          name = SecureRandom.hex
          new_preset = create_document_group_preset(name)
          expected_differences = [
            ['DocumentGroup.count', 1],
            [
              'DocumentTypesGrouping.count',
              new_preset.document_types.count
            ]
          ]

          assert_differences(expected_differences) do
            post copy_document_group_preset_url(new_preset, as: users(role))
          end

          new_document_group = DocumentGroup.find_by(name: name)

          assert_redirects_with_flash_success(document_group_path(new_document_group))
          assert_equal name, new_document_group.name
          assert_equal @account.id, new_document_group.account_id
          new_preset.document_types.each do |type|
            assert_equal type['required'], grouping_for(new_document_group, type['id']).required
          end
        end
      end
    end
  end

  describe '#destroy' do
    it_requires_authenticated_user { delete document_group_preset_url(@preset) }

    test 'as super_admin' do
      assert_difference 'DocumentGroupPreset.count', -1 do
        delete document_group_preset_url(@preset, as: users(:super_admin))
      end
      assert_redirects_with_flash_success(document_group_presets_path)
    end

    [:account_owner, :account_manager, :employee].each do |role|
      test "as #{role}" do
        delete document_group_preset_url(@preset, as: users(role))

        assert_redirects_with_not_authorized_error
      end
    end
  end

  private

  def type_for(preset, document_type)
    preset.document_types.find do |dt|
      dt['id'] == document_type.id
    end
  end

  def grouping_for(document_group, document_type_id)
    document_group.document_types_groupings.find do |dtg|
      dtg.document_type_id == document_type_id
    end
  end
end
